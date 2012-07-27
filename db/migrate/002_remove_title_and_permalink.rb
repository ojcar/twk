class RemoveTitleAndPermalink < ActiveRecord::Migration
  def self.up
    remove_column :snippets, :title
    remove_column :snippets, :permalink
  end

  def self.down
    add_column :snippets, :title, :string
    add_column :snippets, :permalink, :string
  end
end
