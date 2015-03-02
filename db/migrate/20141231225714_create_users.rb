class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider
      t.string :uid
      t.text :subscribed_ids, default: nil

      t.timestamps
    end
  end
end
