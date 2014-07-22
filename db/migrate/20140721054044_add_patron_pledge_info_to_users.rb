class AddPatronPledgeInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :patrons, :integer
    add_column :users, :monthly_pledge, :integer
  end
end
