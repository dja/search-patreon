class AddSocialDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :youtube_count, :integer
    add_column :users, :twitter_count, :integer
    add_column :users, :facebook_count, :integer
  end
end
