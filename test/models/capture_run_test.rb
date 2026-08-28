require "test_helper"

class CaptureRunTest < ActiveSupport::TestCase
  test "defaults to pending" do
    assert CaptureRun.new.pending?
  end
end
