class AddIpAddressesToStandups < ActiveRecord::Migration
  def change
    add_column :standups, :ip_addresses_string, :text
  end
end
