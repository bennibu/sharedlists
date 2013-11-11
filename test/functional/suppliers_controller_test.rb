require File.dirname(__FILE__) + '/../test_helper'
require 'suppliers_controller'

# Re-raise errors caught by the controller.
class SuppliersController; def rescue_action(e) raise e end; end

class SuppliersControllerTest < ActionDispatch::IntegrationTest
  fixtures :suppliers

  def test_should_get_index
    get '/suppliers'
    assert_response :success
    assert assigns(:suppliers)
  end

  def test_should_get_new
    get '/suppliers/new'
    assert_response :success
  end
  
  def test_should_create_supplier
    old_count = Supplier.count
    post '/suppliers', :supplier => suppliers(:two)
    assert_equal old_count+1, Supplier.count
    
    assert_redirected_to supplier_path(assigns(:supplier))
  end

  def test_should_show_supplier
    get '/suppliers/1'
    assert_response :success
  end

  def test_should_get_edit
    get '/suppliers/1/edit'
    assert_response :success
  end
  
  def test_should_update_supplier
    put '/suppliers/1', :supplier => { }
    assert_redirected_to suppliers_path(assigns(:supplier))
  end
  
  def test_should_destroy_supplier
    old_count = Supplier.count
    delete '/suppliers/1'
    assert_equal old_count-1, Supplier.count
    
    assert_redirected_to suppliers_path
  end
end
