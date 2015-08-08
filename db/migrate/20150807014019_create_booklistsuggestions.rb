class CreateBooklistsuggestions < ActiveRecord::Migration
  def change
    create_table :booklistsuggestions do |t|
      t.string :gwid
      t.string :section
      t.string :crn
      t.string :isbn
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
