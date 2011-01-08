require 'test_helper'

class RecordFormatsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => RecordFormat.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    RecordFormat.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    RecordFormat.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to record_format_url(assigns(:record_format))
  end
  
  def test_edit
    get :edit, :id => RecordFormat.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    RecordFormat.any_instance.stubs(:valid?).returns(false)
    put :update, :id => RecordFormat.first
    assert_template 'edit'
  end

  def test_update_valid
    RecordFormat.any_instance.stubs(:valid?).returns(true)
    put :update, :id => RecordFormat.first
    assert_redirected_to record_format_url(assigns(:record_format))
  end
  
  def test_destroy
    record_format = RecordFormat.first
    delete :destroy, :id => record_format
    assert_redirected_to record_formats_url
    assert !RecordFormat.exists?(record_format.id)
  end
end
