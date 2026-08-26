class Admin::BaseController < ApplicationController
  before_action :require_admin

  private
    def require_admin
      redirect_to root_path, alert: "Você não tem permissão para acessar esta área." unless current_user&.admin?
    end

    def record_activity(action, auditable = nil, metadata = {})
      current_user.activity_logs.create!(action:, auditable:, metadata:)
    end
end
