#!/usr/bin/ruby

guard_opts = {
  all_on_start:   true,
  all_after_pass: true,
}

def all
  'spec'
end

guard 'rspec' do
  watch(%r{^spec/.+\.rb})
  watch(%r{^.+\.rb}) { |m| "spec/#{m[0]}" }
  watch(%r{^Gemfile$})                      { all }
  watch(%r{^Gemfile.lock$})                 { all }
end
