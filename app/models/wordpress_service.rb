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

  def public_url
    "http://#{host}/community"
  end

  private

  def connection
    server = XMLRPC::Client.new(@host, @endpoint_path, "80", nil, nil, @host_basic_auth_user, @host_basic_auth_password, false, 900)

    # Due to the following bug in the Ruby 2.0.0-p0 Standard Library
    # https://bugs.ruby-lang.org/issues/8182#change-40965
    # this extra HTTP header is required. The issue may be resolved in 2.1.0
    # allowing this extra header to be removed.
    server.http_header_extra = {'accept-encoding' => 'identity'}

    server
  end

end
