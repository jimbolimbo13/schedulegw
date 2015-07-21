class AddAcceptTermsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :accepted_terms, :boolean, default: false
  end
  def down
    remove_column :users, :accepted_terms
  end
end
