class AddBooklistLockedToCourses < ActiveRecord::Migration
  def up
    add_column :courses, :booklist_locked, :boolean, default: false
    add_column :courses, :booklist_lock_conflict, :boolean, default: false
  end
  def down
    remove_column :courses, :booklist_locked
    remove_column :courses, :booklist_lock_conflict
  end
end
