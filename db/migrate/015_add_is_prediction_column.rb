class AddIsPredictionColumn < ActiveRecord::Migration
  def self.up
    add_column :snippets, :is_prediction, :boolean
  end

  def self.down
    remove_column :snippets, :is_prediction
  end
end
