class CaptureRunJob < ApplicationJob
  queue_as :captures

  def perform(date = Date.current, newspaper_id: nil, force: false)
    date = Date.parse(date) if date.is_a?(String)
    run = CaptureRun.find_or_create_by!(scheduled_for: date)
    return run if run.completed? && !force && newspaper_id.nil?

    newspapers = Newspaper.active.alphabetical
    newspapers = newspapers.where(id: newspaper_id) if newspaper_id.present?
    targets = newspapers.flat_map { |newspaper| viewports_for(newspaper).map { |viewport| [ newspaper, viewport ] } }

    run.update!(status: :running, started_at: Time.current, finished_at: nil)

    screenshots = targets.map do |newspaper, viewport|
      screenshot = Screenshot.find_or_initialize_by(newspaper:, captured_on: date, viewport:)
      screenshot.capture_run = run
      screenshot.source_url = newspaper.homepage_url
      screenshot.status = :pending if force && screenshot.failed?
      screenshot.save!
      screenshot
    end

    run.update!(expected_count: run.screenshots.count)
    screenshots.each { |screenshot| CaptureScreenshotJob.perform_now(screenshot.id) unless screenshot.completed? }

    run.reload
  rescue StandardError => error
    run&.update!(status: :failed, finished_at: Time.current, error_summary: error.message.to_s.truncate(2_000))
    raise
  end

  private
    def viewports_for(newspaper)
      [].tap do |viewports|
        viewports << :desktop if newspaper.desktop_enabled?
        viewports << :mobile if newspaper.mobile_enabled?
      end
    end
end
