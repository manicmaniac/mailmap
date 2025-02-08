# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name(File.basename(Process.argv0))
SimpleCov.enable_coverage(:branch)
SimpleCov.at_fork.call(Process.pid)
