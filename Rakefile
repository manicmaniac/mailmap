# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new

begin
  require 'steep/rake_task'

  Steep::RakeTask.new
rescue LoadError
  # For Ruby 2.7
  desc 'Run steep check'
  task :steep do
    sh 'steep check'
  end
end

task default: %i[steep test rubocop]

namespace :test do
  desc 'Generate test cases'
  task generate: ['test/exe/check_mailmap_compatibility_test.rb']
end

file 'test/exe/check_mailmap_compatibility_test.rb' => 'test/exe/check_mailmap_compatibility_test.rb.erb' do |task|
  require 'erb'
  require 'rubocop'

  erb = ERB.new(File.read(task.source), trim_mode: '-')
  File.write(task.name, erb.result)
  options = {
    autocorrect: true,
    display_only_fail_level_offenses: true,
    formatters: [[RuboCop::Formatter::QuietFormatter, nil]],
    only: ['Style/StringLiterals']
  }
  config_store = RuboCop::ConfigStore.new
  exit(RuboCop::Runner.new(options, config_store).run([task.name]))
end
