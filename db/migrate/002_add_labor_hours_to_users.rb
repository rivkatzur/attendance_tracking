class AddLaborHoursToUsers < ActiveRecord::Migration
  def change
    add_column :users, :labor_hours, :float
  end
end
