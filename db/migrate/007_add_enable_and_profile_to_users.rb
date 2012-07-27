class AddEnableAndProfileToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :enabled, :boolean, :default => true
    add_column :users, :profile, :text
  end

  def self.down
    remove_column :users, :enabled
    remove_column :users, :profile
  end
end
