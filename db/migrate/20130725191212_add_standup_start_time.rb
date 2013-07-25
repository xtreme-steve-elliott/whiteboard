class AddStandupStartTime < ActiveRecord::Migration
  def change
    add_column :standups, :start_time_string, :string, default: '9:06am'
  end
end
