source 'https://rubygems.org'
ruby '2.0.0'
gem 'rails', '4.0.0'

gem 'pg'
gem 'unicorn'
gem 'jquery-rails'
gem 'omniauth-google-apps'
gem 'github-markdown', require: 'github/markdown'
gem 'exceptional'
gem 'protected_attributes'
gem 'cf'
gem 'logs-cf-plugin'
gem 'ruby-openid', git: 'git://github.com/kendagriff/ruby-openid.git', ref: '79beaa419d4754e787757f2545331509419e222e'

group :production do
  gem 'rails_12factor'
end

group :test, :development do
  gem 'rspec-rails', '2.14.0'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-accessible'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pry-debugger'
  gem 'letter_opener'
  gem 'timecop'
  gem 'foreman'
  gem 'fakefs', :require => 'fakefs/safe'
  gem 'dotenv', '~> 0.9.0'
end

group :development do
  gem 'debugger'
  gem 'heroku'
  gem 'heroku_san'
end

gem 'sass-rails'
gem "compass-rails", "~> 2.0.alpha.0"  # alpha required for Rails 4 support
gem 'coffee-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass-rails'

