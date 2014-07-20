class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :site
      t.string :url
      t.string :description
      t.references :user, index: true

      t.timestamps
    end
  end
end
