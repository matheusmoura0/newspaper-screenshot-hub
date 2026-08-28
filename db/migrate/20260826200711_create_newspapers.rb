class CreateNewspapers < ActiveRecord::Migration[8.1]
  def change
    create_table :newspapers do |t|
      t.string :name
      t.string :slug
      t.string :homepage_url
      t.string :category
      t.string :country
      t.string :time_zone
      t.time :capture_time
      t.boolean :desktop_enabled
      t.boolean :mobile_enabled
      t.boolean :active
      t.jsonb :capture_options

      t.timestamps
    end
  end
end
