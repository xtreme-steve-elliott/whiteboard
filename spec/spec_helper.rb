ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'capybara/rails'
require 'capybara/rspec'
require 'support/mock_auth' # TODO: figure out why the rails root join didn't work below
Capybara.javascript_driver = :accessible_selenium
Capybara.default_driver = :accessible_webkit
Selenium::WebDriver::Firefox::Binary.path = ENV['FIREFOX_BINARY_PATH'] || Selenium::WebDriver::Firefox::Binary.path

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:each, :type => :feature) do |example|
    if example.exception
      artifact = save_page
      puts "\"#{example.description}\" failed. Page saved to #{artifact}"
    end
  end

  config.around(:each, inaccessible: true) do |example|
    Capybara::Accessible.skip_audit { example.run }
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.render_views

  config.include FactoryGirl::Syntax::Methods
  config.include MockAuth
  config.include Capybara::DSL

  def click_on_preferences(page)
    page.find('a.btn.btn-navbar').click if page.has_css?('.btn.btn-navbar')
    click_on 'Preferences'
  end

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
