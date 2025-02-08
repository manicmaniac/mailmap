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
  library 'strscan'

  check 'lib'
end
