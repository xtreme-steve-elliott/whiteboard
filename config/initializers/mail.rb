require 'json'

if ENV['VCAP_SERVICES'].present?

  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  # After starting your cloud foundry app run:
  # cf files [app-name] logs/env.log to see the VCAP_SERVICES vars
  credentials = vcap_services['sendgrid'][0]['credentials']

  ActionMailer::Base.smtp_settings = {
    :address => credentials['hostname'],
    :port => '587',
    :authentication => :plain,
    :user_name => credentials['username'],
    :password => credentials['password'],
    :domain => 'cfapps.io'
  }

end
