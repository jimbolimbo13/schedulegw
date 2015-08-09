class AddUrLsToSchoolsModel < ActiveRecord::Migration
  def change
    add_column :schools, :crn_url, :string
    add_column :schools, :exam_url, :string
    add_column :schools, :booklist_url, :string
  end
end
