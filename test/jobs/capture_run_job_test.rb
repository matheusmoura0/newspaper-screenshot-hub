require "test_helper"

class CaptureRunJobTest < ActiveJob::TestCase
  test "creates one screenshot per active viewport without duplicates" do
    date = Date.new(2026, 9, 1)

    stub_capture_job do
      assert_difference -> { Screenshot.count }, 3 do
        CaptureRunJob.perform_now(date)
      end

      assert_no_difference -> { Screenshot.count } do
        CaptureRunJob.perform_now(date)
      end
    end

    run = CaptureRun.find_by!(scheduled_for: date)
    assert_equal 3, run.expected_count
  end

  test "manual batch capture includes every selected newspaper" do
    date = Date.new(2026, 9, 2)
    newspapers(:two).update!(active: false)

    stub_capture_job do |captured_ids|
      assert_difference -> { Screenshot.count }, 3 do
        CaptureRunJob.perform_now(
          date,
          newspaper_ids: [ newspapers(:one).id, newspapers(:two).id ],
          force: true
        )
      end

      captured_newspaper_ids = captured_ids.map { |id| Screenshot.find(id).newspaper_id }.uniq.sort
      assert_equal [ newspapers(:one).id, newspapers(:two).id ].sort, captured_newspaper_ids
    end
  end

  test "forced manual capture reruns a completed screenshot from the same day" do
    date = Date.new(2026, 9, 3)
    newspaper = newspapers(:one)
    newspaper.update!(mobile_enabled: false)

    stub_capture_job do |captured_ids|
      CaptureRunJob.perform_now(date, newspaper_id: newspaper.id, force: true)

      screenshot = Screenshot.find_by!(newspaper:, captured_on: date, viewport: :desktop)
      screenshot.update!(status: :completed, captured_at: Time.current)
      screenshot.capture_run.update!(status: :completed, finished_at: Time.current)

      CaptureRunJob.perform_now(date, newspaper_id: newspaper.id, force: true)

      assert_equal [ screenshot.id, screenshot.id ], captured_ids
      assert_predicate screenshot.reload, :pending?
      assert_nil screenshot.captured_at
    end
  end

  private
    def stub_capture_job
      original_perform_now = CaptureScreenshotJob.method(:perform_now)
      captured_ids = []
      CaptureScreenshotJob.define_singleton_method(:perform_now) { |id| captured_ids << id }

      yield captured_ids
    ensure
      CaptureScreenshotJob.define_singleton_method(:perform_now, original_perform_now) if original_perform_now
    end
end
