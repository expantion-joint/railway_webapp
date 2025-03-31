class DailyReportJob < ApplicationJob
  queue_as :default

  def perform
    csv = DailyReportService.generate_csv
    DailyReportMailer.send_report(csv).deliver_now
  end
end
