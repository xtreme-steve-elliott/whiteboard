Rails.application.config.blogging_service = WordpressService.new.tap do |service|
  service.host = ENV['WORDPRESS_BLOG_HOST']
  service.host_basic_auth_user = ENV['WORDPRESS_BASIC_AUTH_USER']
  service.host_basic_auth_password = ENV['WORDPRESS_BASIC_AUTH_PASSWORD']
  service.endpoint_path = ENV['WORDPRESS_XMLRPC_ENDPOINT_PATH']
  service.wordpress_username = ENV['WORDPRESS_USER']
  service.wordpress_password = ENV['WORDPRESS_PASSWORD']
end
