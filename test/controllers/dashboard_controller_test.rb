require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_redirected_to new_session_url
  end

  test "authenticated user gets dashboard" do
    sign_in_as users(:one)
    get root_url
    assert_response :success
  end
end
