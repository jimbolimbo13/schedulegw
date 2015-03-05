class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :provider
      t.string :email
      t.string :uid
      t.text :subscribed_ids, default: nil
      t.boolean :admin, default: false
      t.integer :school_id

      t.timestamps
    end
  end
end
