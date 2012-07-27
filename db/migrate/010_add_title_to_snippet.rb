class AddTitleToSnippet < ActiveRecord::Migration
  def self.up
    add_column :snippets, :title, :string
  end

  def self.down
    remove_column :snippets, :title
  end
end
