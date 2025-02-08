# frozen_string_literal: true

target :exe do
  unreferenced!
  implicitly_returns_nil!
  signature 'sig/exe'
  library 'optparse'

  check 'exe/check-mailmap'
end

target :lib do
  signature 'sig'
  ignore_signature 'sig/test'
  library 'strscan'

  check 'lib'
end

target :test do
  unreferenced!
  implicitly_returns_nil!
  signature 'sig/test'
  library 'minitest'
  library 'open3'
  library 'tempfile'

  check 'test/**/*_test.rb'
end
