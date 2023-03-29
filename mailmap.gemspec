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

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
end
