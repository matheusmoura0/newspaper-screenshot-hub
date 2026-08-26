class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Defina sua senha — Newspaper Screenshot Hub", to: user.email_address
  end
end
