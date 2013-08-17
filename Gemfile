#!/usr/bin/ruby

source 'https://rubygems.org/'

group :development, :test do
  gem 'rspec', '~> 2.14.0'
  gem 'fuubar'

  gem 'guard-rspec'
  #gem 'guard', github: 'aspiers/guard', branch: 'master'
  gem 'guard-bundler'

  gem 'jazz_hands'

  gem 'simplecov', require: false

  gem 'capistrano' #, github: 'aspiers/capistrano', branch: 'master'
  gem 'capistrano-unicorn'
  gem 'rvm-capistrano', github: 'aspiers/rvm-capistrano', branch: 'rvm-user'
end

group :staging, :production do
  gem 'unicorn'
end
