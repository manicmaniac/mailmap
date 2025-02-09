# frozen_string_literal: true

require_relative 'lib/mailmap/version'

Gem::Specification.new do |spec|
  spec.name          = 'mailmap'
  spec.version       = Mailmap::VERSION
  spec.authors       = ['Ryosuke Ito']
  spec.email         = ['rito.0305@gmail.com']
  spec.summary       = 'Parser for Git Mailmap (.mailmap)'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/manicmaniac/mailmap'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/manicmaniac/mailmap/issues',
    'documentation_uri' => 'https://www.rubydoc.info/gems/mailmap',
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true'
  }
  spec.bindir = 'exe'
  spec.executables = ['check-mailmap']
  spec.files = Dir['lib/**/*.rb', 'sig/**/*.rbs', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']
end
