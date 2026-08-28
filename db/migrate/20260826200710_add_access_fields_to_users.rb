class AddAccessFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :role, :integer
    add_column :users, :active, :boolean
    add_column :users, :invited_at, :datetime
    add_column :users, :accepted_invitation_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
  end
end
