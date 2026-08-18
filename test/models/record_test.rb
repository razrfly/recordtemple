# == Schema Information
#
# Table name: records
#
#  id               :integer          not null, primary key
#  cached_artist    :string(255)
#  cached_label     :string(255)
#  comment          :text
#  condition        :integer
#  value            :integer
#  created_at       :datetime
#  updated_at       :datetime
#  artist_id        :integer
#  genre_id         :integer
#  identifier_id    :integer
#  label_id         :integer
#  price_id         :integer
#  record_format_id :integer
#  user_id          :integer
#
# Indexes
#
#  index_records_on_artist_id         (artist_id)
#  index_records_on_genre_id          (genre_id)
#  index_records_on_label_id          (label_id)
#  index_records_on_price_id          (price_id)
#  index_records_on_record_format_id  (record_format_id)
#  index_records_on_user_id           (user_id)
#  records_fts_idx                    (to_tsvector('english'::regconfig, COALESCE(comment, ''::text))) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id)
#  fk_rails_...  (genre_id => genres.id)
#  fk_rails_...  (label_id => labels.id)
#  fk_rails_...  (price_id => prices.id)
#  fk_rails_...  (record_format_id => record_formats.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class RecordTest < ActiveSupport::TestCase
  # Media introspection driving the tiered delete confirmation (#384).
  setup do
    @genre  = Genre.create!(name: "Model Test Genre")
    @label  = Label.create!(name: "Model Test Label")
    @format = RecordFormat.create!(name: "Model Test Format",
                                   record_type: RecordType.create!(name: "Model Test Type"))
    @user   = User.find_or_create_by!(id: 1) { |u| u.email = "collection-owner@example.com" }
    @record = build_record("Model Test Artist")
  end

  test "has_media? is false with no attachments" do
    assert_not @record.has_media?
  end

  test "has_media? is true with images only" do
    attach_image(@record)
    assert @record.has_media?
  end

  test "has_media? is true with audio only" do
    attach_audio(@record)
    assert @record.has_media?
  end

  test "media_counts reports each collection separately" do
    2.times { attach_image(@record) }
    attach_audio(@record)
    assert_equal({ images: 2, songs: 1 }, @record.media_counts)
  end

  test "media_bytes sums images and audio" do
    attach_image(@record)  # "png-bytes" => 9
    attach_audio(@record)  # "mp3-bytes" => 9
    assert_equal 18, @record.media_bytes
  end

  test "media_bytes still reports when the stored file is missing (#346)" do
    # ~200 images are known missing from S3. The blob row (and its byte_size)
    # survives, so the confirm page must still render rather than 500.
    # Note an attachment cannot be orphaned from its blob: the schema has an FK
    # on active_storage_attachments.blob_id, so blob is never nil here.
    attach_image(@record)
    @record.images.first.blob.delete # removes the stored file, not the row

    assert_nothing_raised { @record.media_bytes }
    assert_equal 9, @record.media_bytes
  end

  test "destroying a record destroys its legacy photo and song rows" do
    Photo.create!(record: @record, image_filename: "cover.png")
    Song.create!(record: @record, audio_filename: "track.mp3")

    assert_difference(["Photo.count", "Song.count"], -1) do
      @record.destroy!
    end
  end

  test "destroying a record leaves its price guide entry intact" do
    price = Price.create!(artist: @record.artist, record_format: @format, detail: "Model Test Pressing")
    @record.update!(price: price)

    assert_no_difference("Price.count") { @record.destroy! }
    assert Price.exists?(price.id)
  end

  private

  def build_record(artist_name)
    Record.create!(
      user: @user,
      condition: :mint,
      artist: Artist.create!(name: artist_name),
      genre: @genre,
      label: @label,
      record_format: @format
    )
  end

  def attach_image(record)
    record.images.attach(io: StringIO.new("png-bytes"), filename: "cover.png", content_type: "image/png")
  end

  def attach_audio(record)
    record.songs.attach(io: StringIO.new("mp3-bytes"), filename: "track.mp3", content_type: "audio/mpeg")
  end
end
