# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'

SimpleCov.start do
  load_profile 'test_frameworks'
  enable_coverage :branch
end

require 'mailmap'
require 'minitest/autorun'
