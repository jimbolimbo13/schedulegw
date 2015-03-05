class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :name
      t.integer :user_id
      t.integer :course_id

      t.timestamps null: false
    end
  end
end
