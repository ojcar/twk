class AddPredictionIdToSnippet < ActiveRecord::Migration
  def self.up
    add_column :snippets, :prediction_id, :integer
    remove_column :snippets, :is_prediction
    remove_column :predictions, :snippet_id
  end

  def self.down
  end
end
