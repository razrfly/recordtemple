require 'test_helper'

class UserAccountsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => UserAccount.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    UserAccount.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    UserAccount.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to user_account_url(assigns(:user_account))
  end
  
  def test_edit
    get :edit, :id => UserAccount.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    UserAccount.any_instance.stubs(:valid?).returns(false)
    put :update, :id => UserAccount.first
    assert_template 'edit'
  end

  def test_update_valid
    UserAccount.any_instance.stubs(:valid?).returns(true)
    put :update, :id => UserAccount.first
    assert_redirected_to user_account_url(assigns(:user_account))
  end
  
  def test_destroy
    user_account = UserAccount.first
    delete :destroy, :id => user_account
    assert_redirected_to user_accounts_url
    assert !UserAccount.exists?(user_account.id)
  end
end
