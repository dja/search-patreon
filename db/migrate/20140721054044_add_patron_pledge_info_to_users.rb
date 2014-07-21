class AddPatronPledgeInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :patrons, :string
    add_column :users, :monthly_pledge, :string
  end
end
