require "test_helper"
require "passwordless/test_helpers"

module Admin
  # Covers the dedicated Discogs coverage facet (?discogs=...), the coverage
  # progress strip, and the ?pricing=has_discogs back-compat mapping added in #390.
  # Follows the harness established by RecordsMediaFilterTest: sign in any user
  # (User#admin? is always true) and own the records with COLLECTION_USER_ID,
  # since the controller hard-filters on that id.
  class RecordsDiscogsFilterTest < ActionDispatch::IntegrationTest
    include Passwordless::TestHelpers::RequestTestCase

    COLLECTION_USER_ID = Admin::RecordsController::COLLECTION_USER_ID

    setup do
      @owner = User.find_or_create_by!(id: COLLECTION_USER_ID) do |u|
        u.email = "collection-owner@example.com"
      end
      passwordless_sign_in(@owner)

      @genre  = Genre.create!(name: "Test Genre")
      @label  = Label.create!(name: "Test Label")
      @format = RecordFormat.create!(name: "Test Format", record_type: RecordType.create!(name: "Test Type"))

      # Guide prices give the rows a deterministic best_value ordering:
      # priced (500) > matched-no-price (400) > unmatched (300) > skipped (200).
      @priced = create_record("Priced Artist", price_high: 500,
                              release: create_release(1001, lowest_price: 42.50))
      @matched_no_price = create_record("Matched No Price Artist", price_high: 400,
                                        release: create_release(1002, lowest_price: nil))
      @unmatched = create_record("Unmatched Artist", price_high: 300)
      @skipped = create_record("Skipped Artist", price_high: 200,
                               skip_review: true, skip_reason: "no release exists")
    end

    # --- The five filter options ---------------------------------------------

    test "discogs=has_price returns only records with a Discogs price" do
      get admin_records_path(discogs: "has_price")
      assert_response :success
      assert_rows_shown ["Priced Artist"]
    end

    test "discogs=missing_price returns both gap states and excludes skipped" do
      get admin_records_path(discogs: "missing_price")
      assert_response :success
      assert_rows_shown ["Matched No Price Artist", "Unmatched Artist"]
    end

    test "discogs=unmatched returns only records with no Discogs match" do
      get admin_records_path(discogs: "unmatched")
      assert_response :success
      assert_rows_shown ["Unmatched Artist"]
    end

    test "discogs=matched_no_price returns only matched records lacking a price" do
      get admin_records_path(discogs: "matched_no_price")
      assert_response :success
      assert_rows_shown ["Matched No Price Artist"]
    end

    test "discogs=skipped surfaces deliberately skipped records on purpose" do
      get admin_records_path(discogs: "skipped")
      assert_response :success
      assert_rows_shown ["Skipped Artist"]
    end

    test "unmatched and matched_no_price partition missing_price" do
      get admin_records_path(discogs: "unmatched")
      assert_not_includes @response.body, "Matched No Price Artist"
      get admin_records_path(discogs: "matched_no_price")
      assert_not_includes @response.body, "Unmatched Artist"
    end

    # --- Composition ----------------------------------------------------------

    test "missing_price composes with sort, direction and top_n" do
      get admin_records_path(discogs: "missing_price", sort: "best_value", direction: "desc", top_n: 1000)
      assert_response :success
      assert_rows_shown ["Matched No Price Artist", "Unmatched Artist"]
      assert_operator body_index("Matched No Price Artist"), :<, body_index("Unmatched Artist")
    end

    test "missing_price honours an ascending sort direction" do
      get admin_records_path(discogs: "missing_price", sort: "best_value", direction: "asc")
      assert_response :success
      assert_operator body_index("Unmatched Artist"), :<, body_index("Matched No Price Artist")
    end

    test "missing_price composes with price source and a min value floor" do
      get admin_records_path(discogs: "missing_price", price_source: "guide", min_value: 350)
      assert_response :success
      # Guide values are condition-adjusted; all records are mint (1.0x), so the
      # $300 unmatched record falls below the floor while the $400 one survives.
      assert_rows_shown ["Matched No Price Artist"]
    end

    test "discogs facet composes with the pricing dropdown rather than competing with it" do
      get admin_records_path(discogs: "missing_price", pricing: "has_guide")
      assert_response :success
      assert_rows_shown ["Matched No Price Artist", "Unmatched Artist"]
    end

    # --- Back-compat ----------------------------------------------------------

    test "legacy pricing=has_discogs maps to the new discogs=has_price filter" do
      get admin_records_path(pricing: "has_discogs")
      assert_response :success
      assert_rows_shown ["Priced Artist"]
      assert_select "select[name=discogs] option[value=has_price][selected]"
    end

    test "an explicit discogs param wins over the legacy pricing value" do
      get admin_records_path(pricing: "has_discogs", discogs: "unmatched")
      assert_response :success
      assert_rows_shown ["Unmatched Artist"]
    end

    test "the pricing dropdown no longer offers has_discogs" do
      get admin_records_path
      assert_response :success
      assert_select "select[name=pricing] option[value=has_discogs]", count: 0
    end

    # --- CSV ------------------------------------------------------------------

    test "CSV export respects the discogs filter" do
      get admin_records_path(format: :csv, discogs: "missing_price")
      assert_response :success
      rows = CSV.parse(@response.body, headers: true)
      assert_equal ["Matched No Price Artist", "Unmatched Artist"], rows.map { |r| r["Artist"] }.sort
      assert rows.all? { |r| r["Discogs Lowest Price"].blank? },
             "expected every exported row to be missing a Discogs price"
    end

    # --- Coverage stat card ---------------------------------------------------

    test "the stats bar carries a Discogs coverage card" do
      get admin_records_path
      assert_response :success
      # 4 records: priced (has price) + skipped (counted as resolved) = 2 of 4.
      assert_select "div", text: "Discogs Coverage"
      assert_includes @response.body, "2 / 4"
      assert_includes @response.body, "50%"
      # The skipped count lives in the card's tooltip.
      assert_select "div[title=?]", "1 deliberately skipped, counted as resolved"
    end

    test "the coverage card ignores the filter dropdowns" do
      get admin_records_path(discogs: "missing_price")
      assert_response :success
      # The table below shows 2 rows; the card still reports 2 of 4,
      # the same way Total Records and Total Value do.
      assert_includes @response.body, "2 / 4"
    end

    test "a text search narrows the coverage card and Total Records together" do
      # Search is the one input that does move these cards, so the card's
      # denominator must stay equal to whatever Total Records reports — a
      # collection-wide numerator over a searched denominator would contradict
      # the card sitting next to it.
      get admin_records_path(search: "Skipped Artist")
      assert_response :success
      total = total_records_card_count
      assert_operator total, :<, 4, "expected the search to narrow the collection"
      assert_includes @response.body, "#{total} / #{total}"
      assert_includes @response.body, "100%"
    end

    test "tied rows are ordered deterministically so a deep link is reproducible" do
      # Every fixture record is mint with a distinct guide price, so force a tie
      # by sorting on a column they all share.
      orders = Array.new(3) do
        get admin_records_path(discogs: "missing_price", sort: "condition", direction: "desc")
        ["Matched No Price Artist", "Unmatched Artist"].sort_by { |n| body_index(n) }
      end
      assert_equal 1, orders.uniq.size, "row order varied across requests: #{orders.inspect}"
    end

    # --- Filter bar -----------------------------------------------------------

    test "the discogs dropdown labels carry live counts" do
      get admin_records_path
      assert_response :success
      assert_select "select[name=discogs] option[value=missing_price]", text: /Missing Discogs price \(2\)/
      assert_select "select[name=discogs] option[value=unmatched]",     text: /Not matched \(1\)/
      assert_select "select[name=discogs] option[value=matched_no_price]", text: /Matched, no price \(1\)/
      assert_select "select[name=discogs] option[value=skipped]",       text: /Skipped \(1\)/
      assert_select "select[name=discogs] option[value=has_price]",     text: /Has Discogs price \(1\)/
    end

    test "clear-filters link renders when only the discogs filter is active" do
      get admin_records_path(discogs: "missing_price")
      assert_response :success
      assert_select "a", text: "Clear filters"
    end

    test "the table distinguishes not-matched from matched-without-a-price" do
      get admin_records_path(discogs: "missing_price")
      assert_response :success
      assert_select "span[title=?]", "Matched to Discogs, no price — needs a re-fetch"
      assert_select "span[title=?]", "Not matched to Discogs"
    end

    private

    ARTIST_NAMES = ["Priced Artist", "Matched No Price Artist", "Unmatched Artist", "Skipped Artist"].freeze

    # Asserts exactly the expected artists appear and the rest do not. Guards
    # against a substring match: "Matched No Price Artist" does not contain
    # "Unmatched Artist", so plain include/exclude checks are unambiguous here.
    def assert_rows_shown(expected)
      expected.each { |name| assert_includes @response.body, name }
      (ARTIST_NAMES - expected).each { |name| assert_not_includes @response.body, name }
    end

    def create_record(artist_name, price_high:, release: nil, skip_review: false, skip_reason: nil)
      artist = Artist.create!(name: artist_name)
      Record.create!(
        user_id: COLLECTION_USER_ID,
        condition: :mint,
        artist: artist,
        genre: @genre,
        label: @label,
        record_format: @format,
        # Price belongs_to :artist and :record_format (both required).
        price: Price.create!(price_high: price_high, price_low: price_high / 2,
                             artist: artist, record_format: @format),
        discogs_release: release,
        discogs_skip_review: skip_review,
        discogs_skip_reason: skip_reason
      )
    end

    def create_release(discogs_id, lowest_price:)
      DiscogsRelease.create!(
        discogs_id: discogs_id,
        title: "Release #{discogs_id}",
        lowest_price: lowest_price,
        fetched_at: Time.current
      )
    end

    # The number rendered on the Total Records card, which is also the
    # denominator the Discogs Coverage card is required to use.
    def total_records_card_count
      node = css_select("div").find { |d| d.text.strip == "Total Records" }
      assert_not_nil node, "expected a Total Records stat card"
      Integer(node.next_element.text.delete(","))
    end

    def body_index(text)
      idx = @response.body.index(text)
      assert_not_nil idx, "expected #{text.inspect} to appear in the response body"
      idx
    end
  end
end
