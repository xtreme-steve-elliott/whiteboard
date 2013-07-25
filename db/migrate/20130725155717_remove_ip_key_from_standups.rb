class RemoveIpKeyFromStandups < ActiveRecord::Migration
  def up
    remove_column :standups, :ip_key
  end

  def down
    add_column :standups, :ip_key, :string
  end
end
