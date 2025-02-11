# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

task default: %i[steep test rubocop]

Rake::TestTask.new(test: %i[coverage:clean]) do |t|
  t.libs += %w[lib test]
  t.pattern = 'test/**/*_test.rb'
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

namespace :coverage do
  desc 'Remove coverage reports'
  task :clean do
    FileUtils.rm_rf(File.expand_path('../coverage', __FILE__))
  end
end

task generate: %i[generate:parser generate:test]

namespace :generate do
  desc 'Generate parser'
  task parser: ['lib/mailmap/parser.rb']

  desc 'Generate test cases'
  task test: ['test/exe/check_mailmap_compatibility_test.rb']
end

rule '.rb' => '.y' do |task|
  sh 'racc', '--embedded', '--frozen', '--output-file', task.name, task.source
end

rule '.rb' => '.rb.erb' do |task|
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
