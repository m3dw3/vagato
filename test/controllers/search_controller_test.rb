require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get search" do
    get :filter
    assert_response :success
  end

end
