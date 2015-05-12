class AddIsbn < ActiveRecord::Migration
  def change
    add_column :courses, :isbn, :json, unique: true, default: []
  end

end
