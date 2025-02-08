# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tempfile'
require 'test_helper'

class CheckMailmapTest < Minitest::Test
  parallelize_me!

  def run(*args, **kwargs, &block)
    @git_dir = Dir.mktmpdir
    Minitest.after_run do
      FileUtils.remove_dir(@git_dir)
      @git_dir = nil
    end
    git_init(@git_dir)
    super
  end

  def test_executable
    assert(File.executable?(EXECUTABLE_PATH))
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

  mailmap_patterns = {
    name_email: "Proper Name <commit@email.xx>\n",
    email_email: "<proper@email.xx> <commit@email.xx>\n",
    name_email_email: "Proper Name <proper@email.xx> <commit@email.xx>\n",
    name_email_name_email: "Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n",
    email_name_email: "<proper@email.xx> Commit Name <commit@email.xx>\n",
    comment: "# Comment\n",
    trailing_comment: "Proper Name <commit@email.xx> # Comment\n",
    invalid_name: "Commit Name\n",
    invalid_name_name: "Proper Name Commit Name\n",
    invalid_email: "<commit@email.xx>\n"
  }

  contact_patterns = {
    email: '<commit@email.xx>',
    name_email: 'Commit Name <commit@email.xx>',
    wrong_email: '<wrong@email.xx>',
    invalid_name: 'Commit Name'
  }

  mailmap_patterns.each do |mailmap_key, mailmap_value|
    contact_patterns.each do |contact_key, contact_value|
      define_method("test_compatibility_on_#{mailmap_key}_with_#{contact_key}") do
        Tempfile.create('mailmap', @git_dir) do |mailmap|
          mailmap.write(mailmap_value)
          mailmap.rewind

          expected = git_check_mailmap(contact_value, mailmap_path: mailmap.path)
          actual = check_mailmap(contact_value, mailmap_path: mailmap.path)

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

  def git_init(dir)
    git_dir = File.join(dir, '.git')
    FileUtils.makedirs([File.join(git_dir, 'objects'), File.join(git_dir, 'refs')])
    File.write(File.join(git_dir, 'HEAD'), 'ref: refs/heads/main')
  end

  def check_mailmap(*args, mailmap_path: '', stdin_data: nil)
    Open3.capture3(RbConfig.ruby, '-r', SIMPLECOV_SPAWN_PATH, EXECUTABLE_PATH, '-f', mailmap_path, *args,
                   stdin_data: stdin_data)
  end

  def git_check_mailmap(*args, mailmap_path: '', stdin_data: nil)
    Open3.capture3('git', '-C', @git_dir, '-c', "mailmap.file=#{mailmap_path}", 'check-mailmap', *args,
                   stdin_data: stdin_data)
  end
end
