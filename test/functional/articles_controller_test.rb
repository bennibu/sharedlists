require File.dirname(__FILE__) + '/../test_helper'
require 'articles_controller'

# Re-raise errors caught by the controller.
class ArticlesController; def rescue_action(e) raise e end; end

class ArticlesControllerTest < Test::Unit::TestCase
  fixtures :articles, :suppliers

  def setup
    @controller = ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index, :supplier_id => suppliers(:one)
    assert_response :success
    assert assigns(:articles)
  end

  def test_should_get_new
    get :new, :supplier_id => suppliers(:one)
    assert_response :success
  end
  
  def test_should_create_article
    old_count = Article.count
    post :create, :supplier_id => suppliers(:one), :article => {:name => "testarticle" }
    assert_equal old_count+1, Article.count
    
    assert_redirected_to supplier_article_path(suppliers(:one), assigns(:article))
  end

  def test_should_show_article
    get :show, :id => 1, :supplier_id => suppliers(:one)
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1, :supplier_id => suppliers(:one)
    assert_response :success
  end
  
  def test_should_update_article
    put :update, :id => 1, :supplier_id => suppliers(:one), :article => {:name => "testarticle" }
    assert_redirected_to supplier_article_path(suppliers(:one), assigns(:article))
  end
  
  def test_should_destroy_article
    old_count = Article.count
    delete :destroy, :id => 1, :supplier_id => suppliers(:one)
    assert_equal old_count-1, Article.count
    
    assert_redirected_to articles_path(suppliers(:one))
  end
end
