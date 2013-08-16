require 'simplecov'
SimpleCov.start

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

shared_context "pending", pending: true do
  before { pending }
end
