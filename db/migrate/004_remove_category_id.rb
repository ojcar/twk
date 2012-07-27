class RemoveCategoryId < ActiveRecord::Migration
  def self.up
    remove_column :snippets, :category_id
    change_column :snippets, :flag, :boolean, :default => true
    change_column :snippets, :how_truthful, :integer, :default => 0
  end

  def self.down
    add_column :snippets, :category_id, :integer
    change_column :snippets, :flag, :boolean
    change_column :snippets, :how_truthful, :integer
  end
end
