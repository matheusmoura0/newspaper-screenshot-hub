class ScreenshotsController < ApplicationController
  def index
    @date = params[:date].present? ? Date.iso8601(params[:date]) : (Screenshot.maximum(:captured_on) || Date.current)
    @screenshots = Screenshot.completed.where(captured_on: @date).includes(:newspaper, image_attachment: :blob)
    @screenshots = @screenshots.where(newspaper_id: params[:newspaper_id]) if params[:newspaper_id].present?
    @screenshots = @screenshots.where(viewport: params[:viewport]) if params[:viewport].present?
    @newspapers = Newspaper.alphabetical
  rescue Date::Error
    redirect_to screenshots_path, alert: "Data inválida."
  end

  def show
    @screenshot = Screenshot.completed.includes(:newspaper, image_attachment: :blob).find(params[:id])
  end
end
