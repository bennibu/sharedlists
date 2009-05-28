require File.dirname(__FILE__) + '/../test_helper'
require 'suppliers_controller'

# Re-raise errors caught by the controller.
class SuppliersController; def rescue_action(e) raise e end; end

class SuppliersControllerTest < Test::Unit::TestCase
  fixtures :suppliers

  def setup
    @controller = SuppliersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:suppliers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_supplier
    old_count = Supplier.count
    post :create, :supplier => { }
    assert_equal old_count+1, Supplier.count
    
    assert_redirected_to supplier_path(assigns(:supplier))
  end

  def test_should_show_supplier
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_supplier
    put :update, :id => 1, :supplier => { }
    assert_redirected_to supplier_path(assigns(:supplier))
  end
  
  def test_should_destroy_supplier
    old_count = Supplier.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Supplier.count
    
    assert_redirected_to suppliers_path
  end
end
