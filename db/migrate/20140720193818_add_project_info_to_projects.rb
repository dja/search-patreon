class AddProjectInfoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :created_date, :string
    add_column :projects, :patrons, :string
  end
end
