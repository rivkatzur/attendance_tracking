class CreateDailySummaries < ActiveRecord::Migration
  def change
    create_table :daily_summaries do |t|
      t.references :user
      t.references :project
      t.date :spent_on
      t.float :hours
    end
    add_index :daily_summaries, :user_id
    add_index :daily_summaries, :spent_on
  end
end
