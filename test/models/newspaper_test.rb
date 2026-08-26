require "test_helper"

class NewspaperTest < ActiveSupport::TestCase
  test "generates slug from name" do
    newspaper = Newspaper.new(name: "Correio da Manhã", homepage_url: "https://example.com", time_zone: "America/Sao_Paulo", capture_time: "08:00", desktop_enabled: true)
    newspaper.validate
    assert_equal "correio-da-manha", newspaper.slug
  end

  test "requires at least one viewport" do
    newspaper = newspapers(:one)
    newspaper.desktop_enabled = false
    newspaper.mobile_enabled = false
    assert_not newspaper.valid?
  end
end
