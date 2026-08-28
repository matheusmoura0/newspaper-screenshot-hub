class CreateCaptureRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :capture_runs do |t|
      t.date :scheduled_for
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status
      t.integer :expected_count
      t.integer :completed_count
      t.integer :failed_count
      t.text :error_summary

      t.timestamps
    end
  end
end
