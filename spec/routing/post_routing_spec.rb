require 'spec_helper'

describe PostsController do
  it "routes send_email" do
    put("/posts/1/send_email").should route_to("posts#send_email", :id => "1")
  end

  it "routes to post_to_blog" do
    put("/posts/1/post_to_blog").should route_to("posts#post_to_blog", :id => "1")
  end

  it "routes to archive" do
    put("/posts/1/archive").should route_to("posts#archive", :id => "1")
  end

  it "routes to archived" do
    get('/posts/archived').should route_to("posts#archived")
  end
end
