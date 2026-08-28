require "json"
require "open3"

class CapturePage
  class Error < StandardError; end

  SCRIPT_PATH = Rails.root.join("script/capture_page.py").freeze
  VIEWPORTS = {
    "desktop" => { width: 1440, height: 1200, scale: 1 },
    "mobile" => { width: 430, height: 932, scale: 2 }
  }.freeze

  def self.call(url:, viewport:, output_path:, options: {})
    settings = VIEWPORTS.fetch(viewport.to_s)
    command = [
      ENV.fetch("PYTHON_BIN", "python3"), SCRIPT_PATH.to_s,
      "--url", url,
      "--output", output_path.to_s,
      "--width", settings[:width].to_s,
      "--height", settings[:height].to_s,
      "--scale", settings[:scale].to_s,
      "--options", options.to_json
    ]

    stdout, stderr, status = Open3.capture3(*command)
    raise Error, [ stderr, stdout ].reject(&:blank?).join("\n").truncate(2_000) unless status.success? && File.size?(output_path)

    JSON.parse(stdout.lines.last || "{}")
  rescue JSON::ParserError => error
    raise Error, "A captura terminou sem metadados válidos: #{error.message}"
  end
end
