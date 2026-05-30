require "test_helper"
require "passwordless/test_helpers"

module Admin
  # Covers the return_to plumbing added to the Discogs review flow (issue #380):
  # linking/skipping from a record's admin page must return to that record, while
  # the batch-queue workflow must still return to the queue.
  #
  # Covers both `link` and `skip`. `skip` is a pure DB update. `link` normally
  # fetches from Discogs, but DiscogsReleaseService#find_or_fetch checks the DB
  # first, so pre-seeding a DiscogsRelease with the posted discogs_id exercises the
  # real link path with no API call (the suite has no stubbing gem). A dummy
  # DISCOGS_API_TOKEN is set only so DiscogsApiClient's constructor — which the
  # services build eagerly — doesn't raise; no request is made. `show` is not
  # request-tested here because it always hits the live Discogs search API.
  class DiscogsReviewReturnToTest < ActionDispatch::IntegrationTest
    include Passwordless::TestHelpers::RequestTestCase

    COLLECTION_USER_ID = Admin::DiscogsReviewController::COLLECTION_USER_ID

    setup do
      @original_discogs_token = ENV["DISCOGS_API_TOKEN"]
      ENV["DISCOGS_API_TOKEN"] = "test-token"

      @owner = User.find_or_create_by!(id: COLLECTION_USER_ID) do |u|
        u.email = "collection-owner@example.com"
      end
      passwordless_sign_in(@owner)

      @genre  = Genre.create!(name: "Test Genre")
      @label  = Label.create!(name: "Test Label")
      @format = RecordFormat.create!(name: "Test Format", record_type: RecordType.create!(name: "Test Type"))

      @record = create_record("Skip Test Artist")
    end

    teardown do
      ENV["DISCOGS_API_TOKEN"] = @original_discogs_token
    end

    test "skip with a record return_to redirects back to that record" do
      post skip_admin_discogs_review_path(@record),
        params: { reason: "no_match", return_to: admin_record_path(@record) }
      assert_redirected_to admin_record_path(@record)
      assert @record.reload.discogs_skip_review
    end

    test "skip without return_to redirects to the queue" do
      post skip_admin_discogs_review_path(@record), params: { reason: "no_match" }
      assert_redirected_to admin_discogs_review_index_path
    end

    test "skip with a protocol-relative return_to falls back to the queue" do
      post skip_admin_discogs_review_path(@record),
        params: { reason: "no_match", return_to: "//evil.com" }
      assert_redirected_to admin_discogs_review_index_path
    end

    test "skip with a non-whitelisted return_to falls back to the queue" do
      post skip_admin_discogs_review_path(@record),
        params: { reason: "no_match", return_to: "/etc/passwd" }
      assert_redirected_to admin_discogs_review_index_path
    end

    test "skip with a path-traversal return_to falls back to the queue" do
      post skip_admin_discogs_review_path(@record),
        params: { reason: "no_match", return_to: "/admin/../secret" }
      assert_redirected_to admin_discogs_review_index_path
    end

    test "link with a record return_to redirects back to that record" do
      release = seed_release(900_001)
      post link_admin_discogs_review_path(@record),
        params: { discogs_id: release.discogs_id, return_to: admin_record_path(@record) }
      assert_redirected_to admin_record_path(@record)
      assert_equal release, @record.reload.discogs_release
    end

    test "link without return_to redirects to the queue" do
      release = seed_release(900_002)
      post link_admin_discogs_review_path(@record),
        params: { discogs_id: release.discogs_id }
      assert_redirected_to admin_discogs_review_index_path
      assert_equal release, @record.reload.discogs_release
    end

    test "link with a hostile return_to falls back to the queue but still links" do
      release = seed_release(900_003)
      post link_admin_discogs_review_path(@record),
        params: { discogs_id: release.discogs_id, return_to: "//evil.com" }
      assert_redirected_to admin_discogs_review_index_path
      assert_equal release, @record.reload.discogs_release
    end

    private

    # Pre-seed a DiscogsRelease so DiscogsReleaseService#find_or_fetch returns it
    # from the DB and the link path runs without touching the Discogs API.
    def seed_release(discogs_id)
      DiscogsRelease.create!(discogs_id: discogs_id, title: "Seeded #{discogs_id}", fetched_at: Time.current)
    end

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
  end
end
