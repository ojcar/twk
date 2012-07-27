class AddPredictionColumnToSnippet < ActiveRecord::Migration
  def self.up
    add_column :snippets, :is_prediction, :boolean, :default => 'false'
  end

  def self.down
    remove_column :snippets, :is_prediction
  end
end
