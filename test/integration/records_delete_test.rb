require "test_helper"
require "passwordless/test_helpers"

# Covers the two-tier record delete flow added in #384, plus the legacy-orphan
# cascade from #385 that unblocked it.
#
# The acceptance gate is the server-side tier re-derivation: a record can gain
# attachments between page render and submit, and the Tier A path is a plain
# DELETE that a client could aim at a media-bearing record. If #destroy does not
# re-check, the typed confirmation is decorative. Tests 2-4 pin that.
#
# Harness follows test/integration/admin/records_media_filter_test.rb: the
# records/users/prices fixtures are intentionally empty, so everything is built
# explicitly, and User#admin? is always true so ownership is what actually gates.
class RecordsDeleteTest < ActionDispatch::IntegrationTest
  include Passwordless::TestHelpers::RequestTestCase

  COLLECTION_USER_ID = ApplicationController::COLLECTION_USER_ID

  setup do
    @owner = User.find_or_create_by!(id: COLLECTION_USER_ID) do |u|
      u.email = "collection-owner@example.com"
    end

    @genre  = Genre.create!(name: "Test Genre")
    @label  = Label.create!(name: "Test Label")
    @format = RecordFormat.create!(name: "Test Format", record_type: RecordType.create!(name: "Test Type"))

    @no_media   = create_record("No Media Artist")
    @with_media = create_record("Media Artist")
    attach_image(@with_media)
    attach_audio(@with_media)

    passwordless_sign_in(@owner)
  end

  # --- Tier A: no media, one request ---------------------------------------

  test "Tier A deletes in a single request" do
    assert_difference("Record.count", -1) do
      delete record_path(@no_media)
    end
    assert_redirected_to records_path
    assert_equal %(Deleted "#{@no_media.title}".), flash[:notice]
  end

  test "show page renders the Tier A button and no confirm_delete link" do
    get record_path(@no_media)
    assert_response :success
    assert_select "form[action=?][method=?]", record_path(@no_media), "post"
    assert_not_includes @response.body, confirm_delete_record_path(@no_media)
  end

  # --- Tier B: media present, typed confirmation ---------------------------

  test "Tier B refuses without a confirm param" do
    assert_no_difference("Record.count") do
      delete record_path(@with_media)
    end
    assert_redirected_to confirm_delete_record_path(@with_media)
    assert_equal "Type DELETE exactly to confirm.", flash[:alert]
    assert Record.exists?(@with_media.id)
  end

  test "Tier B refuses a near-miss confirmation" do
    assert_no_difference("Record.count") do
      delete record_path(@with_media), params: { confirm: "delete" }
    end
    assert_redirected_to confirm_delete_record_path(@with_media)
    assert_equal "Type DELETE exactly to confirm.", flash[:alert]
  end

  test "Tier B succeeds with confirm=DELETE" do
    title = @with_media.title
    assert_difference("Record.count", -1) do
      delete record_path(@with_media), params: { confirm: "DELETE" }
    end
    assert_redirected_to records_path
    assert_equal %(Deleted "#{title}" along with 1 image and 1 audio file. ) +
                 "The price guide entry was kept.", flash[:notice]
  end

  test "attachments are removed when the record is deleted" do
    assert_difference("ActiveStorage::Attachment.count", -2) do
      delete record_path(@with_media), params: { confirm: "DELETE" }
    end
    assert_empty ActiveStorage::Attachment.where(record_type: "Record", record_id: @with_media.id)
  end

  test "confirm page renders for the owner" do
    get confirm_delete_record_path(@with_media)
    assert_response :success
    assert_select "h1", "Delete this record?"
    assert_includes @response.body, "Type DELETE to confirm"
    assert_includes @response.body, "Kept — not affected by this delete"
    assert_not_includes @response.body, "and all associated data"
  end

  test "confirm page renders when a blob is missing from storage (#346)" do
    # ~200 images are known missing from S3. Detection is client-side (the
    # image-loader controller uncovers a placeholder), so the server must render
    # the page without ever asking storage whether the file is there.
    blob = @with_media.images.first.blob
    blob.service.delete(blob.key)

    get confirm_delete_record_path(@with_media)
    assert_response :success
    assert_select "h1", "Delete this record?"
  end

  test "confirm page drops the typed confirmation for a record with no media" do
    # The admin Danger Zone links every record here, so the page has to degrade:
    # demanding a typed DELETE for zero files is friction with nothing behind it.
    get confirm_delete_record_path(@no_media)
    assert_response :success
    assert_select "input[name=?]", "confirm", false
    assert_includes @response.body, "Nothing is destroyed"
    assert_includes @response.body, "No images or audio are attached"
  end

  test "confirm page offers the remove-individual-files escape hatch" do
    get confirm_delete_record_path(@with_media)
    assert_select "a[href=?]", admin_record_path(@with_media, anchor: "media")
  end

  test "show page links to the confirm page for a media record" do
    get record_path(@with_media)
    assert_response :success
    assert_select "a[href=?]", confirm_delete_record_path(@with_media)
  end

  # --- Blast radius: shared catalog data must survive -----------------------

  test "deleting a record does not delete its price guide entry" do
    price = Price.create!(artist: @with_media.artist, record_format: @format, detail: "Test Pressing")
    @with_media.update!(price: price)

    assert_no_difference("Price.count") do
      delete record_path(@with_media), params: { confirm: "DELETE" }
    end
    assert Price.exists?(price.id), "price guide entry must survive a record delete"
  end

  test "deleting a record does not delete its artist label or genre" do
    artist_id = @no_media.artist_id
    delete record_path(@no_media)

    assert Artist.exists?(artist_id)
    assert Label.exists?(@label.id)
    assert Genre.exists?(@genre.id)
  end

  test "deleting a record destroys its legacy photo and song rows" do
    Photo.create!(record: @no_media, image_filename: "cover.png")
    Song.create!(record: @no_media, audio_filename: "track.mp3")

    assert_difference(["Photo.count", "Song.count"], -1) do
      delete record_path(@no_media)
    end
  end

  # --- Authorization and edge cases ----------------------------------------

  test "signed out visitor cannot delete" do
    passwordless_sign_out(User)

    assert_no_difference("Record.count") do
      delete record_path(@no_media)
    end
    assert_redirected_to root_path
  end

  test "signed out visitor cannot reach the confirm page" do
    passwordless_sign_out(User)

    get confirm_delete_record_path(@with_media)
    assert_redirected_to root_path
  end

  test "non-owner cannot delete" do
    passwordless_sign_out(User)
    # Explicit id: @owner is inserted with a literal id 1, so the sequence has
    # not advanced past it and an auto-assigned id would collide.
    intruder = User.create!(id: COLLECTION_USER_ID + 1_000, email: "intruder@example.com")
    passwordless_sign_in(intruder)

    assert_no_difference("Record.count") do
      delete record_path(@no_media)
    end
    assert_redirected_to records_path
    assert_equal "Not authorized.", flash[:alert]
  end

  test "deleting an already deleted record redirects instead of 404ing" do
    id = @no_media.id
    @no_media.destroy!

    delete record_path(id)
    assert_redirected_to records_path
    assert_equal "That record no longer exists.", flash[:alert]
  end

  test "admin danger zone links into the shared confirm flow" do
    get admin_record_path(@with_media)
    assert_response :success
    assert_select "a[href=?]", confirm_delete_record_path(@with_media), text: "Delete this record…"
    assert_not_includes @response.body, "and all associated data"
  end

  test "admin danger zone renders for a record with no media" do
    get admin_record_path(@no_media)
    assert_response :success
    assert_includes @response.body, "No images or audio are attached"
  end

  test "the admin destroy route no longer exists" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/records/#{@no_media.id}", method: :delete)
    end
  end

  private

  def create_record(artist_name)
    Record.create!(
      user_id: COLLECTION_USER_ID,
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
