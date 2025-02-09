# frozen_string_literal: true

require 'open3'
require 'tempfile'
require 'test_helper'

class CheckMailmapTest < Minitest::Test
  def test_executable
    assert(File.executable?(EXECUTABLE_PATH))
  end

  def test_no_args
    stdout, stderr, status = check_mailmap

    refute_predicate(status, :success?)
    assert_empty(stdout)
    assert_match(/usage:/, stderr)
  end

  def test_help
    stdout, stderr, status = check_mailmap('--help')

    assert_predicate(status, :success?, stderr)
    assert_match(/usage:/, stdout)
  end

  def test_version
    stdout, stderr, status = check_mailmap('--version')

    assert_predicate(status, :success?, stderr)
    assert_match(/^check-mailmap \d+[.]\d+[.]\d+\n$/, stdout)
  end

  def test_stdin
    stdout, stderr, status = Tempfile.create do |mailmap|
      mailmap.write("Proper Name <commit@email.xx>\n")
      mailmap.rewind
      check_mailmap('--stdin', mailmap_path: mailmap.path, stdin_data: '<commit@email.xx>')
    end

    assert_equal("Proper Name <commit@email.xx>\n", stdout)
    assert_empty(stderr)
    assert_predicate(status, :success?)
  end

  def test_invalid_mailmap_path
    stdout, stderr, status = check_mailmap('<commit@email.xx>', mailmap_path: 'invalid-path')

    assert_empty(stdout)
    assert_match(/fatal: No such file or directory/, stderr)
    refute_predicate(status, :success?)
  end

  private

  EXECUTABLE_PATH = File.expand_path('../../../exe/check-mailmap', __FILE__)
  private_constant :EXECUTABLE_PATH

  def check_mailmap(*args, mailmap_path: nil, stdin_data: nil)
    command = [
      RbConfig.ruby,
      '-r',
      File.expand_path('../../simplecov_spawn.rb', __FILE__),
      EXECUTABLE_PATH
    ]
    command += ['-f', mailmap_path] if mailmap_path
    command += args
    Open3.capture3(*command, stdin_data: stdin_data)
  end
end
