class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
    	t.string :name
    	t.text :display_name 
    	t.string :email_stub
    	t.string :initials
      t.timestamps null: false
    end
  end
end
