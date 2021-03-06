require 'test_helper'

class CoordinatesControllerTest < ActionController::TestCase
  setup do
    @coordinate = coordinates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:coordinates)
  end

  test "should get new_owner" do
    get :new_owner
    assert_response :success
  end

  test "should create coordinate" do
    assert_difference('Coordinate.count') do
      post :create, coordinate: { address_id: @coordinate.address_id, latitude: @coordinate.latitude, longitude: @coordinate.longitude }
    end

    assert_redirected_to coordinate_path(assigns(:coordinate))
  end

  test "should show coordinate" do
    get :show, id: @coordinate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @coordinate
    assert_response :success
  end

  test "should update coordinate" do
    patch :update, id: @coordinate, coordinate: { address_id: @coordinate.address_id, latitude: @coordinate.latitude, longitude: @coordinate.longitude }
    assert_redirected_to coordinate_path(assigns(:coordinate))
  end

  test "should destroy coordinate" do
    assert_difference('Coordinate.count', -1) do
      delete :destroy, id: @coordinate
    end

    assert_redirected_to coordinates_path
  end
end
