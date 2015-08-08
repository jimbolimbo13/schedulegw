class AddImageUrLtoListbook < ActiveRecord::Migration
  def up
    add_column :listbooks, :image_url, :string
  end
end
