source 'https://rubygems.org'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'nokogiri', '>= 1.7.1' # >= 1.7.1 due to CVE-2016-4658
gem 'rubyzip',  '>= 1.2.1' # >= 1.2.1 due to CVE-2017-5946

gem 'paranoia', '~> 2.0'
gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter'
gem 'composite_primary_keys', '~> 8.0'
gem "pg"
gem 'activerecord-import'
gem 'charlock_holmes', require: false
gem "rails"
gem 'bcrypt'
gem "haml-rails"
gem "sass-rails"
gem 'autoprefixer-rails'
gem 'kaminari'
gem 'with_advisory_lock', git: 'https://github.com/eanders/with_advisory_lock.git', branch: 'MSSQL-support'
gem 'schema_plus_views'
gem 'memoist', require: false

# File processing
gem 'carrierwave'
# this doesn't install cleanly on a Mac
# We aren't currently using this anyway
# gem 'seven_zip_ruby', group: :seven_zip

gem 'devise', '~> 3.5'
gem 'devise_invitable'
gem 'paper_trail'
gem 'validates_email_format_of'
gem 'text'

gem "lograge"
gem 'activerecord-session_store'
gem 'attribute_normalizer'
gem 'delayed_job_active_record'
gem 'uglifier'
gem 'daemons'

gem "simple_form"
gem 'virtus'

# Asset related
gem 'bootstrap-sass'
gem "jquery-rails"
gem 'coffee-rails'
gem 'handlebars_assets'
gem 'execjs'
gem 'sprockets-es6'
gem 'select2-rails'
gem 'font-awesome-sass'
# gem 'chart-js-rails'
gem 'nominatim'

# ETO API related
gem "rest-client", "~> 2.0"
gem "gmail", require: false

# for de-duping clients
gem 'redcarpet'

# For exporting
# As of 2017-05-02 the most recent rubygem version of axlsx
# depended on nokogiri and rubyzip with active CVE's
# we needed https://github.com/randym/axlsx/commit/776037c0fc799bb09da8c9ea47980bd3bf296874
# and https://github.com/randym/axlsx/commit/e977cf5232273fa45734cdb36f6fae4db2cbe781
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'axlsx_rails'
# gem 'wicked_pdf'
# gem 'wkhtmltopdf-binary'

gem 'whenever', require: false
gem 'ruby-progressbar', require: false

gem 'slack-notifier'
gem 'exception_notification'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'puma'
gem 'letsencrypt_plugin'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'newrelic_rpm', require: false
# gem "temping", require: false
gem 'dotenv-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-rails'
  gem 'foreman'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'html2haml'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'capistrano', '~> 3.6.1'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'rails-erd'
  gem 'web-console'
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'list_matcher', require: false   # for the forms:desmush rake task


  gem 'ruby-prof'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph'
  gem 'stackprof'     # For Ruby MRI 2.1+
  gem 'rb-readline'
end

group :test do
  gem "capybara"
  gem "launchy"
  gem 'minitest-reporters'
  gem 'rspec-mocks'
end

group :development, :staging do
  gem 'faker', '>= 1.7.2', require: false
end