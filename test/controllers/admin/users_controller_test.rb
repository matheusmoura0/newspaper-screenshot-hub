require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @member = users(:two)
  end

  test "member cannot access user management" do
    sign_in_as @member

    get admin_users_url

    assert_redirected_to root_url
  end

  test "admin creates user with an initial password without sending email" do
    sign_in_as @admin

    assert_difference("User.count", 1) do
      post admin_users_url, params: {
        user: {
          name: "Novo Usuário",
          email_address: "novo@example.com",
          role: "member",
          active: "1",
          password: "senha-segura",
          password_confirmation: "senha-segura"
        }
      }
    end

    user = User.find_by!(email_address: "novo@example.com")
    assert user.authenticate("senha-segura")
    assert_redirected_to admin_users_url
  end

  test "admin resets another user's password" do
    sign_in_as @admin

    assert_changes -> { @member.reload.password_digest } do
      patch admin_user_url(@member), params: {
        user: {
          name: @member.name,
          email_address: @member.email_address,
          role: @member.role,
          active: "1",
          password: "nova-senha",
          password_confirmation: "nova-senha"
        }
      }
    end

    assert @member.authenticate("nova-senha")
    assert_redirected_to admin_users_url
  end
end
