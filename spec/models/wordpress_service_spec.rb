require 'spec_helper'

describe WordpressService do
  describe "#send!" do
    before do
      subject.wordpress_username = "user"
      subject.wordpress_password = "password"
    end

    it "calls the connection with the attributes for the post" do
      connection = mock("mock_connection")
      subject.should_receive(:connection).and_return(connection)

      connection.should_receive(:call).with(
        'metaWeblog.newPost',
        1,
        "user",
        "password",
        {post: :hash},
        true).and_return("mocked call")

      blog_post = mock("blog post", post_hash: {post: :hash})

      subject.send!(blog_post).should == "mocked call"
    end
  end

  describe "#minimally_configured?" do
    before do
      subject.host = :something
      subject.endpoint_path = :something
      subject.wordpress_username = :something
      subject.wordpress_password = :something
    end

    it "returns true when all the minimally necessary config is set" do
      subject.minimally_configured?.should == true
    end

    it "returns true when the host is missing" do
      subject.host = nil
      subject.minimally_configured?.should == false
    end

    it "returns true when the endpoint path is missing" do
      subject.endpoint_path = nil
      subject.minimally_configured?.should == false
    end

    it "returns true when the wordpress username is missing" do
      subject.wordpress_username = nil
      subject.minimally_configured?.should == false
    end

    it "returns true when the wordpress password is missing" do
      subject.wordpress_password = nil
      subject.minimally_configured?.should == false
    end
  end
end
