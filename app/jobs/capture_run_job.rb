class CaptureRunJob < ApplicationJob
  queue_as :captures

  def perform(date = Date.current, newspaper_id: nil, newspaper_ids: nil, force: false)
    date = Date.parse(date) if date.is_a?(String)
    requested_ids = (Array(newspaper_ids) + Array(newspaper_id)).compact.uniq
    targeted_capture = requested_ids.any?

    run = CaptureRun.find_or_create_by!(scheduled_for: date)
    return run if run.completed? && !force && !targeted_capture

    newspapers = targeted_capture ? Newspaper.where(id: requested_ids).alphabetical : Newspaper.active.alphabetical
    targets = newspapers.flat_map { |newspaper| viewports_for(newspaper).map { |viewport| [ newspaper, viewport ] } }

    run.update!(status: :running, started_at: Time.current, finished_at: nil, error_summary: nil)

    screenshots = targets.map do |newspaper, viewport|
      screenshot = Screenshot.find_or_initialize_by(newspaper:, captured_on: date, viewport:)
      screenshot.capture_run = run
      screenshot.source_url = newspaper.homepage_url

      if force
        screenshot.assign_attributes(
          status: :pending,
          captured_at: nil,
          duration_ms: nil,
          error_code: nil,
          error_message: nil
        )
      end

      screenshot.save!
      screenshot
    end

    run.update!(expected_count: run.screenshots.count)

    if screenshots.empty?
      run.update!(status: :completed, finished_at: Time.current)
    else
      screenshots.each { |screenshot| CaptureScreenshotJob.perform_now(screenshot.id) unless screenshot.completed? }
    end

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
