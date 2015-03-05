class ProfessorList < ActiveRecord::Migration
  def up
  	create_table :professorlists do |t|
      t.string :first_name
      t.string :last_name
      t.integer :prof_id
      t.string :school
      t.timestamps
    end
  end
  def down
  	drop_table :professorlists
  end
end
