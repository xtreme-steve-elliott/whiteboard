class AddBlogPostIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :blog_post_id, :string
  end
end
