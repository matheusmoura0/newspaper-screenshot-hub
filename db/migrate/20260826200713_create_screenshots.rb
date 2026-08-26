class CreateScreenshots < ActiveRecord::Migration[8.1]
  def change
    create_table :screenshots do |t|
      t.references :newspaper, null: false, foreign_key: true
      t.references :capture_run, null: false, foreign_key: true
      t.date :captured_on
      t.datetime :captured_at
      t.integer :viewport
      t.integer :status
      t.integer :attempts
      t.integer :duration_ms
      t.integer :width
      t.integer :height
      t.string :source_url
      t.string :error_code
      t.text :error_message
      t.jsonb :metadata

      t.timestamps
    end
  end
end
