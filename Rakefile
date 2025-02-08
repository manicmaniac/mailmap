# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'Run static type checker'
task :steep do
  sh 'steep check'
end

RuboCop::RakeTask.new

task default: %i[steep test rubocop]

namespace :test do
  desc 'Generate test cases'
  task generate: ['test/exe/check_mailmap_compatibility_test.rb']
end

file 'test/exe/check_mailmap_compatibility_test.rb' => 'test/exe/check_mailmap_compatibility_test.erb' do |task|
  require 'erb'

  erb = ERB.new(File.read(task.source), trim_mode: '-')
  File.write(task.name, erb.result)
  exit(RuboCop::CLI.new.run(['--auto-correct-all', task.name]))
end
