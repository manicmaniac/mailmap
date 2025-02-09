# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'

# https://github.com/simplecov-ruby/simplecov/issues/992#issuecomment-888268256
unless ENV.include?('SIMPLECOV_DEBUG')
  SimpleCov.at_exit do
    $stdout.reopen(File::NULL)
    SimpleCov.result.format!
    $stdout.reopen(STDOUT) # rubocop:disable Style/GlobalStdStream
  end
end

SimpleCov.start do
  load_profile 'test_frameworks'
  enable_coverage :branch
  track_files 'exe/check-mailmap'
end

require 'mailmap'
require 'minitest/autorun'
