class AddImageDaysToStandup < ActiveRecord::Migration
  def change
    add_column :standups, :image_days, :string
  end
end
