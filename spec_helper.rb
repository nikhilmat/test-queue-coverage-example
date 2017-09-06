require 'fileutils'
FileUtils.rm_rf('coverage')

require 'simplecov'
SimpleCov.start do
  add_filter 'test_spec.rb'
end

require_relative 'test'
require 'rspec'
