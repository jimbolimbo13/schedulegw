class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.boolean :resolved
      t.string :crn
      t.string :gwid
      t.string :section
      t.text :comment

      t.timestamps null: false
    end
  end
end
