# frozen_string_literal: true

require 'open3'
require 'tempfile'
require 'test_helper'

class CheckMailmapTest < Minitest::Test
  parallelize_me!

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

  mailmap_patterns = {
    name_email: "Proper Name <commit@email.xx>\n",
    email_email: "<proper@email.xx> <commit@email.xx>\n",
    name_email_email: "Proper Name <proper@email.xx> <commit@email.xx>\n",
    name_email_name_email: "Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n",
    comment: "# Comment\n",
    trailing_comment: "Proper Name <commit@email.xx> # Comment\n",
    invalid_name: "Commit Name\n",
    invalid_name_name: "Proper Name Commit Name\n",
    invalid_email: "<commit@email.xx>\n",
    invalid_email_name_email: "<proper@email.xx> Commit Name <commit@email.xx>\n"
  }

  contact_patterns = {
    email: '<commit@email.xx>',
    name_email: 'Commit Name <commit@email.xx>',
    wrong_email: '<wrong@email.xx>',
    invalid_name: 'Commit Name'
  }

  Enumerator.product(mailmap_patterns, contact_patterns) do |(mailmap_key, mailmap_value), (contact_key, contact_value)|
    define_method("test_compatibility_on_#{mailmap_key}_with_#{contact_key}") do # rubocop:disable Metrics/MethodLength
      Dir.mktmpdir do |tmpdir|
        system('git', '-C', tmpdir, 'init', '--quiet', exception: true)
        Tempfile.create('mailmap', tmpdir) do |mailmap|
          File.write(File.join(tmpdir, '.git', 'config'), "[mailmap]\n\tfile = #{mailmap.path}\n", mode: 'a')
          mailmap.write(mailmap_value)

          expected = git_check_mailmap(contact_value, cwd: tmpdir)
          actual = check_mailmap('-f', mailmap.path, contact_value)

          assert_equal(expected[0], actual[0]) # stdout
          assert_equal(expected[1], actual[1]) # stderr
          assert_equal(expected[2].exitstatus, actual[2].exitstatus) # status
        end
      end
    end
  end

  private

  EXECUTABLE_PATH = File.expand_path('../../exe/check-mailmap', __dir__)
  private_constant :EXECUTABLE_PATH

  SIMPLECOV_SPAWN_PATH = File.expand_path('../simplecov_spawn.rb', __dir__)
  private_constant :SIMPLECOV_SPAWN_PATH

  def check_mailmap(*args, stdin_data: nil)
    Open3.capture3(RbConfig.ruby, '-r', SIMPLECOV_SPAWN_PATH, EXECUTABLE_PATH, *args, stdin_data: stdin_data)
  end

  def git_check_mailmap(*args, cwd: Dir.pwd)
    Open3.capture3('git', '-C', cwd, 'check-mailmap', *args)
  end
end
