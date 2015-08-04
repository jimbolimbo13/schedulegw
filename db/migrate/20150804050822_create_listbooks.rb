class CreateListbooks < ActiveRecord::Migration
  def change
    create_table :listbooks do |t|
      t.string :title
      t.string :amzn_url
      t.string :isbn
      t.timestamps null: false
    end

    create_table :coursebooks do |t|
      t.belongs_to :listbook, index: true
      t.belongs_to :course, index: true
      t.timestamps null: false
    end

  end
end
