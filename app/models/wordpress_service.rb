require 'xmlrpc/client'

class WordpressService
  attr_accessor :host,
                :host_basic_auth_user,
                :host_basic_auth_password,
                :endpoint_path,
                :wordpress_username,
                :wordpress_password

  def send!(blog_post)
    connection.call('metaWeblog.newPost', 1, @wordpress_username, @wordpress_password, blog_post.post_hash, true)
  end

  def minimally_configured?
    !!(host && endpoint_path && wordpress_username && wordpress_password)
  end

  private

  def connection
    XMLRPC::Client.new(@host, @endpoint_path, "80", nil, nil, @host_basic_auth_user, @host_basic_auth_password, false, 900)
  end
end
