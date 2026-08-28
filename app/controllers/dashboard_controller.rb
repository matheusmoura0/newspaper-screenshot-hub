class DashboardController < ApplicationController
  def index
    @capture_run = CaptureRun.recent.first
    @recent_screenshots = Screenshot.completed.recent.includes(:newspaper, image_attachment: :blob).limit(8)
    @active_newspapers = Newspaper.active.count
    @users_count = User.active.count if current_user.admin?
  end
end
