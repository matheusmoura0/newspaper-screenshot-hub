class CaptureScreenshotJob < ApplicationJob
  queue_as :captures

  def perform(screenshot_id)
    screenshot = Screenshot.find(screenshot_id)
    return if screenshot.completed?

    last_error = nil
    3.times do
      screenshot.increment!(:attempts)
      screenshot.update!(status: :processing, error_code: nil, error_message: nil)

      Tempfile.create([ "newspaper-screenshot", ".png" ]) do |file|
        started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        options = (screenshot.newspaper.capture_options || {}).merge("time_zone" => screenshot.newspaper.time_zone)
        metadata = CapturePage.call(url: screenshot.source_url, viewport: screenshot.viewport, output_path: file.path, options:)
        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1_000).round
        file.rewind
        screenshot.image.attach(io: file, filename: filename_for(screenshot), content_type: "image/png")
        screenshot.update!(status: :completed, captured_at: Time.current, duration_ms:, width: metadata["width"], height: metadata["height"], metadata: metadata)
        return
      end
    rescue StandardError => error
      last_error = error
    end

    screenshot.mark_failed!(last_error)
  ensure
    refresh_run(screenshot.capture_run) if screenshot&.capture_run
  end

  private
    def filename_for(screenshot)
      "#{screenshot.captured_on}-#{screenshot.newspaper.slug}-#{screenshot.viewport}.png"
    end

    def refresh_run(run)
      completed = run.screenshots.completed.count
      failed = run.screenshots.failed.count
      pending = run.screenshots.where(status: %i[pending processing]).exists?
      status = if pending then :running elsif failed.positive? then :completed_with_errors else :completed end
      run.update!(completed_count: completed, failed_count: failed, status:, finished_at: (Time.current unless pending))
    end
end
