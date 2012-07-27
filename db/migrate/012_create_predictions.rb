class CreatePredictions < ActiveRecord::Migration
  def self.up
    create_table :predictions do |t|
      t.column :snippet_id, :integer
      t.column :expiration, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :predictions
  end
end
