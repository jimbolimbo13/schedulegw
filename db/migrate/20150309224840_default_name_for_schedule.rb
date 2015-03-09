class DefaultNameForSchedule < ActiveRecord::Migration
  def up
    change_column_default(:schedules, :name, "Unnamed Schedule")
  end
  def down
    change_column_default(:schedules, :name, nil)
  end
end
