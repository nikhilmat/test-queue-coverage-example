require 'bundler/setup'
require_relative '../spec_helper'

ENV['TEST_QUEUE_WORKERS'] = '1'
ENV['TEST_QUEUE_COVERAGE'] = 'true'

require 'test_queue'
require 'test_queue/runner/rspec'

TestQueue::Runner::RSpec.new.execute
