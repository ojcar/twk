class AddCategoryIdToSnippet < ActiveRecord::Migration
  def self.up
    add_column :snippets, :category_id, :integer
  end

  def self.down
    remove_column :snippets, :category_id
  end
end
