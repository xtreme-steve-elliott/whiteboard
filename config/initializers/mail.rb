require 'json'

if ENV['VCAP_SERVICES'].present?

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  # The namespaces for vcap services are defined in the manifest.yml
  credentials = vcap_services["sendgrid-n/a"][0]['credentials']

  ActionMailer::Base.smtp_settings = {
    :address => credentials['hostname'],
    :port => '587',
    :authentication => :plain,
    :user_name => credentials['username'],
    :password => credentials['password'],
    :domain => 'cfapps.io'
  }

end