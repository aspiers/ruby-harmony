#!/usr/bin/ruby

source 'https://rubygems.org/'

gem 'jazz_hands'
gem 'rake'
gem 'google-analytics-rails'

group :development, :test do
  gem 'rspec', '~> 2.14.0'
  gem 'fuubar'

  gem 'guard-rspec'
  #gem 'guard', github: 'aspiers/guard', branch: 'master'
  gem 'guard-bundler'

  # http://blog.55minutes.com/2013/01/lightning-fast-sass-reloading-in-rails-32/
  gem 'guard-livereload', require: false
  gem 'rack-livereload'

  gem 'simplecov', require: false

  # gem 'debugger'

  gem 'capistrano', github: 'aspiers/capistrano', branch: 'app_subdir'
  gem 'capistrano-unicorn', github: 'sosedoff/capistrano-unicorn'
  gem 'rvm-capistrano', github: 'aspiers/rvm-capistrano', branch: 'master'
  gem 'capistrano-deploytags', '>= 0.8.0'
end

gem 'jquery-ui-rails'

group :development, :test, :staging, :production, :rails, :assets do
  gem 'rails', '4.0.0'
  gem 'sass-rails', '~> 4.0.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'haml'
  gem 'coffee-rails', '~> 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'jquery-rails'

  gem 'twitter-bootstrap-rails', github: 'seyhunak/twitter-bootstrap-rails'
  gem 'less-rails'

  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  #gem 'turbolinks'

  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  #gem 'jbuilder', '~> 1.2'
end

group :staging, :production do
  gem 'unicorn'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end
