require "test_helper"

class CaptureRunJobTest < ActiveJob::TestCase
  test "creates one screenshot per active viewport without duplicates" do
    date = Date.new(2026, 9, 1)

    original_perform_now = CaptureScreenshotJob.method(:perform_now)
    CaptureScreenshotJob.define_singleton_method(:perform_now) { |_id| true }

    assert_difference -> { Screenshot.count }, 3 do
      CaptureRunJob.perform_now(date)
    end

    assert_no_difference -> { Screenshot.count } do
      CaptureRunJob.perform_now(date)
    end

    run = CaptureRun.find_by!(scheduled_for: date)
    assert_equal 3, run.expected_count
  ensure
    CaptureScreenshotJob.define_singleton_method(:perform_now, original_perform_now) if original_perform_now
  end
end
