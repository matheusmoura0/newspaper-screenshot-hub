require "test_helper"

class Admin::NewspapersControllerTest < ActionDispatch::IntegrationTest
  test "member cannot access admin area" do
    sign_in_as users(:two)
    get admin_newspapers_url
    assert_redirected_to root_url
  end

  test "admin can access newspapers" do
    sign_in_as users(:one)
    get admin_newspapers_url
    assert_response :success
  end
end
