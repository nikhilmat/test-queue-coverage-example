require 'bundler/setup'
require_relative '../spec_helper'

ENV['TEST_QUEUE_WORKERS'] = '1'

require 'test_queue'
require 'test_queue/runner/rspec'

class Runner < TestQueue::Runner::RSpec
  def summarize
    SimpleCov.result.format!
  end
end

Runner.new.execute
