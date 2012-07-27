class CreateSnippets < ActiveRecord::Migration
  def self.up
    create_table :snippets do |t|
      t.column :title, :string
      t.column :content, :text
      t.column :permalink, :string
      t.column :flag, :boolean
      t.column :user_id, :integer
      t.column :category_id, :integer
      t.column :how_truthful, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :snippets
  end
end
