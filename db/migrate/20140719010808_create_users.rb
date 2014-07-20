class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :youtube
      t.string :twitter
      t.string :facebook
      t.string :patreon

      t.timestamps
    end
  end
end
