class AddImageFolderToStandup < ActiveRecord::Migration
  def change
    add_column :standups, :image_folder, :string
  end
end
