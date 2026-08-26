class HardenMvpSchema < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :role, from: nil, to: 0
    change_column_default :users, :active, from: nil, to: true

    change_column_default :newspapers, :country, from: nil, to: "Brasil"
    change_column_default :newspapers, :time_zone, from: nil, to: "America/Sao_Paulo"
    change_column_default :newspapers, :desktop_enabled, from: nil, to: true
    change_column_default :newspapers, :mobile_enabled, from: nil, to: true
    change_column_default :newspapers, :active, from: nil, to: true
    change_column_default :newspapers, :capture_options, from: nil, to: {}

    change_column_default :capture_runs, :status, from: nil, to: 0
    change_column_default :capture_runs, :expected_count, from: nil, to: 0
    change_column_default :capture_runs, :completed_count, from: nil, to: 0
    change_column_default :capture_runs, :failed_count, from: nil, to: 0

    change_column_default :screenshots, :status, from: nil, to: 0
    change_column_default :screenshots, :attempts, from: nil, to: 0
    change_column_default :screenshots, :metadata, from: nil, to: {}
    change_column_default :activity_logs, :metadata, from: nil, to: {}

    add_index :newspapers, :slug, unique: true
    add_index :newspapers, :active
    add_index :capture_runs, :scheduled_for, unique: true
    add_index :screenshots, %i[newspaper_id captured_on viewport], unique: true, name: "idx_screenshots_daily_viewport"
    add_index :screenshots, %i[captured_on status]
    add_index :activity_logs, %i[auditable_type auditable_id]
  end
end
