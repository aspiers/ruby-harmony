#!/usr/bin/ruby

guard_opts = {
  all_on_start:   true,
  all_after_pass: true,
}

def all
  'spec'
end

guard 'rspec', guard_opts do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^Gemfile$})                      { all }
  watch(%r{^Gemfile.lock$})                 { all }
end
