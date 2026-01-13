# frozen_string_literal: true

require "test_helper"

class DiscogsMatchingServiceTest < ActiveSupport::TestCase
  # Mock API client to avoid needing real credentials in tests
  class MockDiscogsApiClient
    def search(**_args)
      { "results" => [] }
    end
  end

  setup do
    # Create a minimal record for testing
    @record = Record.new(cached_artist: "Test Artist", cached_label: "Test Label")
    @service = DiscogsMatchingService.new(@record, api_client: MockDiscogsApiClient.new)
  end

  test "extract_titles_from_detail extracts quoted titles" do
    assert_equal ["One Night"], @service.send(:extract_titles_from_detail, '7410 "One Night"')
    assert_equal ["Song1", "Song2"], @service.send(:extract_titles_from_detail, '7410 "Song1"/"Song2"')
    assert_equal ["Stormy", "Let Me Tell You"], @service.send(:extract_titles_from_detail, '99177/99178 "Stormy"/"Let Me Tell You"')
  end

  test "extract_titles_from_detail handles non-quoted format with catalog number" do
    assert_equal ["Elvis, Vol. 1"], @service.send(:extract_titles_from_detail, "992 Elvis, Vol. 1")
  end

  test "extract_titles_from_detail returns empty for non-parseable formats" do
    assert_equal [], @service.send(:extract_titles_from_detail, nil)
    assert_equal [], @service.send(:extract_titles_from_detail, "")
    assert_equal [], @service.send(:extract_titles_from_detail, "Elvis, Vol. 1")  # No catalog number
  end

  test "extract_release_title_from_candidate extracts title from Discogs format" do
    assert_equal "one night", @service.send(:extract_release_title_from_candidate, "Elvis Presley - One Night")
    assert_equal "hey jude", @service.send(:extract_release_title_from_candidate, "The Beatles - Hey Jude")
  end

  test "extract_release_title_from_candidate returns empty for invalid formats" do
    assert_equal "", @service.send(:extract_release_title_from_candidate, nil)
    assert_equal "", @service.send(:extract_release_title_from_candidate, "")
    assert_equal "", @service.send(:extract_release_title_from_candidate, "ABBA")  # No dash separator
  end

  test "similarity returns 100 for exact matches" do
    assert_equal 100, @service.send(:similarity, "one night", "one night")
  end

  test "similarity returns low score for different strings" do
    score = @service.send(:similarity, "one night", "some other song")
    assert score < 30, "Expected low similarity score, got #{score}"
  end

  test "WEIGHTS include title with 20% weight" do
    assert_equal 0.20, DiscogsMatchingService::WEIGHTS[:title]
  end

  test "WEIGHTS sum to 1.0" do
    total = DiscogsMatchingService::WEIGHTS.values.sum
    assert_in_delta 1.0, total, 0.01, "Weights should sum to 1.0, got #{total}"
  end
end
