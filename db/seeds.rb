# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")

unless User.exists?(email_address: admin_email)
  admin_password = Rails.env.production? ? ENV.fetch("ADMIN_PASSWORD") : ENV.fetch("ADMIN_PASSWORD", "change-me-in-development")
  User.create!(name: ENV.fetch("ADMIN_NAME", "Administrador"), email_address: admin_email, role: :admin, active: true, password: admin_password, password_confirmation: admin_password)
end
