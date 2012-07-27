class CreateRolesUsersJoin < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.column :role_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    admin_user = User.find_by_login('ojkar')
    admin_role = Role.find_by_name('Admin')
    admin_user.roles << admin_role
  end

  def self.down
    drop_table :roles_users
  end
end
