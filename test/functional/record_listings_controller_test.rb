require 'test_helper'

class RecordListingsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => RecordListing.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    RecordListing.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    RecordListing.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to record_listing_url(assigns(:record_listing))
  end
  
  def test_edit
    get :edit, :id => RecordListing.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    RecordListing.any_instance.stubs(:valid?).returns(false)
    put :update, :id => RecordListing.first
    assert_template 'edit'
  end

  def test_update_valid
    RecordListing.any_instance.stubs(:valid?).returns(true)
    put :update, :id => RecordListing.first
    assert_redirected_to record_listing_url(assigns(:record_listing))
  end
  
  def test_destroy
    record_listing = RecordListing.first
    delete :destroy, :id => record_listing
    assert_redirected_to record_listings_url
    assert !RecordListing.exists?(record_listing.id)
  end
end
