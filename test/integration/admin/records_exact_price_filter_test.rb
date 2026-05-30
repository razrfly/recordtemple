require "test_helper"
require "passwordless/test_helpers"

module Admin
  # Covers exact (non-bucket) price min/max filtering on /admin/records. The
  # histogram slider used to snap to fixed bucket boundaries, but the backend has
  # always accepted arbitrary numeric min_value/max_value; these tests pin that
  # behavior for off-boundary values like $51/$120 and the "no upper bound" case.
  # Uses price_source=my so the filter keys off records.value deterministically.
  class RecordsExactPriceFilterTest < ActionDispatch::IntegrationTest
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

      @cheap  = create_record("Cheap Record",  51)
      @mid    = create_record("Mid Record",    100)
      @upper  = create_record("Upper Record",  120)
      @pricey = create_record("Pricey Record", 500)
    end

    test "exact min/max selects off-boundary values within the range" do
      get admin_records_path(price_source: "my", min_value: 51, max_value: 120)
      assert_response :success
      assert_includes @response.body, "Cheap Record"
      assert_includes @response.body, "Mid Record"
      assert_includes @response.body, "Upper Record"
      assert_not_includes @response.body, "Pricey Record"
    end

    test "min just above a value excludes it (precise floor)" do
      get admin_records_path(price_source: "my", min_value: 52)
      assert_response :success
      assert_not_includes @response.body, "Cheap Record" # 51 < 52
      assert_includes @response.body, "Mid Record"
      assert_includes @response.body, "Upper Record"
      assert_includes @response.body, "Pricey Record"
    end

    test "blank max means no upper bound" do
      get admin_records_path(price_source: "my", min_value: 65)
      assert_response :success
      assert_not_includes @response.body, "Cheap Record" # 51 < 65
      assert_includes @response.body, "Mid Record"
      assert_includes @response.body, "Upper Record"
      assert_includes @response.body, "Pricey Record" # 500 still included — no ceiling
    end

    test "visible min/max inputs render with the active values" do
      get admin_records_path(price_source: "my", min_value: 51, max_value: 120)
      assert_response :success
      assert_select "input[name=min_value][value=?]", "51"
      assert_select "input[name=max_value][value=?]", "120"
    end

    private

    def create_record(artist_name, value)
      Record.create!(
        user_id: COLLECTION_USER_ID,
        condition: :mint,
        value: value,
        artist: Artist.create!(name: artist_name),
        genre: @genre,
        label: @label,
        record_format: @format
      )
    end
  end
end
