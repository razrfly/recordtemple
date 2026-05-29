require "test_helper"
require "passwordless/test_helpers"

module Admin
  # Covers the has/missing images & audio filters and sortable media columns
  # added to /admin/records. There is no prior admin request-test harness, so
  # this also establishes the pattern: sign in any user (User#admin? is always
  # true) and create records owned by COLLECTION_USER_ID, since the controller
  # hard-filters on that id rather than the current user.
  class RecordsMediaFilterTest < ActionDispatch::IntegrationTest
    include Passwordless::TestHelpers::RequestTestCase

    COLLECTION_USER_ID = Admin::RecordsController::COLLECTION_USER_ID

    setup do
      @owner = User.find_or_create_by!(id: COLLECTION_USER_ID) do |u|
        u.email = "collection-owner@example.com"
      end
      passwordless_sign_in(@owner)

      # Record requires genre/label/record_format (belongs_to is required by default);
      # build one of each to share across the test records.
      @genre  = Genre.create!(name: "Test Genre")
      @label  = Label.create!(name: "Test Label")
      @format = RecordFormat.create!(name: "Test Format", record_type: RecordType.create!(name: "Test Type"))

      @both     = create_record("Both Media Artist")
      @img_only = create_record("Images Only Artist")
      @aud_only = create_record("Audio Only Artist")
      @neither  = create_record("No Media Artist")

      attach_image(@both)
      attach_audio(@both)
      attach_image(@img_only)
      attach_audio(@aud_only)
    end

    test "images=has returns only records with images" do
      get admin_records_path(images: "has")
      assert_response :success
      assert_includes @response.body, "Both Media Artist"
      assert_includes @response.body, "Images Only Artist"
      assert_not_includes @response.body, "Audio Only Artist"
      assert_not_includes @response.body, "No Media Artist"
    end

    test "images=missing returns only records without images" do
      get admin_records_path(images: "missing")
      assert_response :success
      assert_includes @response.body, "Audio Only Artist"
      assert_includes @response.body, "No Media Artist"
      assert_not_includes @response.body, "Both Media Artist"
      assert_not_includes @response.body, "Images Only Artist"
    end

    test "audio=has returns only records with audio" do
      get admin_records_path(audio: "has")
      assert_response :success
      assert_includes @response.body, "Both Media Artist"
      assert_includes @response.body, "Audio Only Artist"
      assert_not_includes @response.body, "Images Only Artist"
      assert_not_includes @response.body, "No Media Artist"
    end

    test "audio=missing returns only records without audio" do
      get admin_records_path(audio: "missing")
      assert_response :success
      assert_includes @response.body, "Images Only Artist"
      assert_includes @response.body, "No Media Artist"
      assert_not_includes @response.body, "Both Media Artist"
      assert_not_includes @response.body, "Audio Only Artist"
    end

    test "media filters combine with another filter" do
      # No record has pricing data, so no_price matches all; layering images=missing
      # should still narrow to the two image-less records.
      get admin_records_path(pricing: "no_price", images: "missing")
      assert_response :success
      assert_includes @response.body, "Audio Only Artist"
      assert_includes @response.body, "No Media Artist"
      assert_not_includes @response.body, "Both Media Artist"
      assert_not_includes @response.body, "Images Only Artist"
    end

    test "sort=has_images desc surfaces records with images before those without" do
      get admin_records_path(sort: "has_images", direction: "desc")
      assert_response :success
      assert_operator body_index("Both Media Artist"), :<, body_index("No Media Artist")
    end

    test "sort=has_images asc surfaces records missing images first" do
      get admin_records_path(sort: "has_images", direction: "asc")
      assert_response :success
      assert_operator body_index("No Media Artist"), :<, body_index("Both Media Artist")
    end

    test "sort=has_songs desc surfaces records with audio before those without" do
      get admin_records_path(sort: "has_songs", direction: "desc")
      assert_response :success
      assert_operator body_index("Audio Only Artist"), :<, body_index("Images Only Artist")
    end

    test "sort=has_songs asc surfaces records missing audio first" do
      get admin_records_path(sort: "has_songs", direction: "asc")
      assert_response :success
      assert_operator body_index("Images Only Artist"), :<, body_index("Audio Only Artist")
    end

    test "clear-filters link renders when only a media filter is active" do
      get admin_records_path(images: "missing")
      assert_response :success
      assert_select "a", text: "Clear filters"
    end

    test "with_valuation exposes has_images/has_songs as usable booleans for row badges" do
      both    = Record.where(id: @both.id).with_valuation.first
      neither = Record.where(id: @neither.id).with_valuation.first
      assert both[:has_images], "expected has_images to be truthy"
      assert both[:has_songs], "expected has_songs to be truthy"
      assert_not neither[:has_images], "expected has_images to be falsey"
      assert_not neither[:has_songs], "expected has_songs to be falsey"
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

    def body_index(text)
      idx = @response.body.index(text)
      assert_not_nil idx, "expected #{text.inspect} to appear in the response body"
      idx
    end
  end
end
