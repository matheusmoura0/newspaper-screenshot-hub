namespace :captures do
  desc "Captura todos os jornais ativos para a data atual"
  task run: :environment do
    CaptureRunJob.perform_now(Date.current)
  end

  desc "Reprocessa apenas capturas com falha na data informada (DATE=AAAA-MM-DD)"
  task retry_failed: :environment do
    date = Date.iso8601(ENV.fetch("DATE", Date.current.iso8601))
    Screenshot.failed.where(captured_on: date).find_each { |screenshot| CaptureScreenshotJob.perform_now(screenshot.id) }
  end
end
