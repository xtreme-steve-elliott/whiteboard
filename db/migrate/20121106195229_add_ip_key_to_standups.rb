class AddIpKeyToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :ip_key, :string
  end
end
