require File.dirname(__FILE__) + '/../test_helper'
require 'forums_controller'

# Re-raise errors caught by the controller.
class ForumsController; def rescue_action(e) raise e end; end

class ForumsControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_remember_me_logs_into_home
    @request.cookies['login_token'] = CGI::Cookie.new('login_token',"2;8305f94ab2b92f99137abbc235ee28e5")
    get :index
    assert_equal 2, session[:user_id]
  end

  def test_remember_me_logs_in_when_login_required
    users(:aaron).login_key="8305f94ab2b92f99137abbc235ee28e5"
    users(:aaron).login_key_expires_at=Time.now.utc+1.week
    users(:aaron).save!
    @request.cookies['login_token'] = CGI::Cookie.new('login_token',"1;8305f94ab2b92f99137abbc235ee28e5")
    get :edit, :id => 1
    assert_equal 1, session[:user_id]
  end


  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:forums)
  end

  def test_should_get_new
    login_as :aaron
    get :new
    assert_response :success
  end
  
  def test_should_require_admin
    login_as :sam
    get :new
    assert_redirected_to login_path
  end
  
  def test_should_create_forum
    login_as :aaron
    assert_difference Forum, :count do
      post :create, :forum => { :name => 'yeah' }
    end
    
    assert_redirected_to forums_path
  end

  def test_should_show_forum
    get :show, :id => 1
    assert_response :success
    assert assigns(:topics)
    # sticky should be first
    assert_equal(topics(:sticky), assigns(:topics).first)
  end

  def test_should_get_edit
    login_as :aaron
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_forum
    login_as :aaron
    put :update, :id => 1, :forum => { }
    assert_redirected_to forums_path
  end
  
  def test_should_destroy_forum
    login_as :aaron
    old_count = Forum.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Forum.count
    
    assert_redirected_to forums_path
  end
end
