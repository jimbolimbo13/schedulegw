class AddFinalsToSchools < ActiveRecord::Migration
  def up
    add_column :schools, :final_date_options, :text
    add_column :schools, :final_time_options, :text
  end

  def down
    remove_column :schools, :final_date_options
    remove_column :schools, :final_time_options
  end
end
