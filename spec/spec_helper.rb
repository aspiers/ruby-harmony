require 'simplecov'
SimpleCov.start

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

shared_context "pending", pending: true do
  before { pending }
end
