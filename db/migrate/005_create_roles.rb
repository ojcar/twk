class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.timestamps
    end
    Role.create(:name => 'Admin')
  end

  def self.down
    drop_table :roles
  end
end
