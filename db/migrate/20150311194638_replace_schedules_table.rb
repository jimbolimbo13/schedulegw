class ReplaceSchedulesTable < ActiveRecord::Migration
  def up
    drop_table :schedules

    if ActiveRecord::Base.connection.table_exists? 'schedule_courses'
      drop_table :schedule_courses
    end

    create_table :schedules do |t|
      t.integer :user_id, index: true
      t.string :name, default: "Unnamed Schedule"
      t.string :unique_string
      t.timestamps null: false
    end

    create_table :courseschedules do |t|
      t.belongs_to :course, index: true
      t.belongs_to :schedule, index: true
      t.timestamps null: false
    end

  end
  def down
    drop_table :schedules
    drop_table :courseschedules

    if ActiveRecord::Base.connection.table_exists? 'schedule_courses'
      drop_table :schedule_courses
    end


    create_table :schedules do |t|
      t.string :name, default: "Unnamed Schedule"
      t.integer :user_id
      t.integer :course_id
      t.string :unique_string
      t.timestamps null: false
    end

  end
end

