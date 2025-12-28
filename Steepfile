# frozen_string_literal: true

D = Steep::Diagnostic

target :exe do
  unreferenced!
  implicitly_returns_nil!
  signature 'sig/_exe'
  library 'optparse'

  check 'exe/check-mailmap'
end

target :lib do
  signature 'sig/lib'
  library 'strscan'

  check 'lib'
end

target :test do
  unreferenced!
  implicitly_returns_nil!

  configure_code_diagnostics(D::Ruby.default) do |config|
    config[D::Ruby::UndeclaredMethodDefinition] = nil
  end

  signature 'sig/_test'
  library 'minitest'
  library 'open3'
  library 'tempfile'

  check 'test/**/*_test.rb'
end
