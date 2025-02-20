# frozen_string_literal: true

# This file was generated by `rake test:generate` task using git version 2.39.3 (Apple Git-146).
#
# `CheckMailmapCompatibilityTest`` is a test suite to check compatibility
# between `git check-mailmap` and `check-mailmap` command.
# To not depend on the `git` command at runtime, this test suite is generated statically.

require 'open3'
require 'tempfile'
require 'test_helper'

class CheckMailmapCompatibilityTest < Minitest::Test # rubocop:disable Metrics/ClassLength
  parallelize_me!

  def setup
    @mailmap = Tempfile.new
  end

  def teardown
    @mailmap.close!
  end

  def test_check_mailmap_on_empty_with_email_should_not_be_found
    @mailmap.write("\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_empty_with_name_email_should_not_be_found
    @mailmap.write("\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_empty_with_wrong_email_should_not_be_found
    @mailmap.write("\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_empty_with_invalid_empty_should_not_be_found
    @mailmap.write("\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_empty_with_invalid_name_should_not_be_found
    @mailmap.write("\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_with_email_should_not_be_found
    @mailmap.write("Proper Name Commit Name\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_with_name_email_should_not_be_found
    @mailmap.write("Proper Name Commit Name\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name Commit Name\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name Commit Name\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name Commit Name\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_with_email_should_be_found
    @mailmap.write("Proper Name <commit@email.xx>\n")

    expected = ["Proper Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_with_name_email_should_be_found
    @mailmap.write("Proper Name <commit@email.xx>\n")

    expected = ["Proper Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_email_with_email_should_be_found
    @mailmap.write("<proper@email.xx> <commit@email.xx>\n")

    expected = ["<proper@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_email_with_name_email_should_be_found
    @mailmap.write("<proper@email.xx> <commit@email.xx>\n")

    expected = ["Commit Name <proper@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_email_with_wrong_email_should_not_be_found
    @mailmap.write("<proper@email.xx> <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_email_with_invalid_empty_should_not_be_found
    @mailmap.write("<proper@email.xx> <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_email_with_invalid_name_should_not_be_found
    @mailmap.write("<proper@email.xx> <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_email_with_email_should_be_found
    @mailmap.write("Proper Name Commit Name <commit@email.xx>\n")

    expected = ["Proper Name Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_email_with_name_email_should_be_found
    @mailmap.write("Proper Name Commit Name <commit@email.xx>\n")

    expected = ["Proper Name Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_email_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name Commit Name <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_email_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_name_email_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_email_with_email_should_be_found
    @mailmap.write("Proper Name <proper@email.xx> <commit@email.xx>\n")

    expected = ["Proper Name <proper@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_email_with_name_email_should_be_found
    @mailmap.write("Proper Name <proper@email.xx> <commit@email.xx>\n")

    expected = ["Proper Name <proper@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_email_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_email_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_email_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_name_email_with_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_name_email_with_name_email_should_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["Proper Name <proper@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_name_email_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_name_email_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_name_email_name_email_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_name_email_with_email_should_not_be_found
    @mailmap.write("<proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_name_email_with_name_email_should_be_found
    @mailmap.write("<proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["Commit Name <proper@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_name_email_with_wrong_email_should_not_be_found
    @mailmap.write("<proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_name_email_with_invalid_empty_should_not_be_found
    @mailmap.write("<proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_email_name_email_with_invalid_name_should_not_be_found
    @mailmap.write("<proper@email.xx> Commit Name <commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_comment_with_email_should_not_be_found
    @mailmap.write("# Comment\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_comment_with_name_email_should_not_be_found
    @mailmap.write("# Comment\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_comment_with_wrong_email_should_not_be_found
    @mailmap.write("# Comment\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_comment_with_invalid_empty_should_not_be_found
    @mailmap.write("# Comment\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_comment_with_invalid_name_should_not_be_found
    @mailmap.write("# Comment\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_trailing_comment_with_email_should_be_found
    @mailmap.write("Proper Name <commit@email.xx> # Comment\n")

    expected = ["Proper Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_trailing_comment_with_name_email_should_be_found
    @mailmap.write("Proper Name <commit@email.xx> # Comment\n")

    expected = ["Proper Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_trailing_comment_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx> # Comment\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_trailing_comment_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx> # Comment\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_trailing_comment_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name <commit@email.xx> # Comment\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_with_email_should_not_be_found
    @mailmap.write("Commit Name\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_with_name_email_should_not_be_found
    @mailmap.write("Commit Name\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_with_wrong_email_should_not_be_found
    @mailmap.write("Commit Name\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_with_invalid_empty_should_not_be_found
    @mailmap.write("Commit Name\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_with_invalid_name_should_not_be_found
    @mailmap.write("Commit Name\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_email_name_with_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_email_name_with_name_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_email_name_with_wrong_email_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_email_name_with_invalid_empty_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_name_email_name_with_invalid_name_should_not_be_found
    @mailmap.write("Proper Name <proper@email.xx> Commit Name\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_with_email_should_not_be_found
    @mailmap.write("<commit@email.xx>\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_with_name_email_should_not_be_found
    @mailmap.write("<commit@email.xx>\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_with_wrong_email_should_not_be_found
    @mailmap.write("<commit@email.xx>\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_with_invalid_empty_should_not_be_found
    @mailmap.write("<commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_with_invalid_name_should_not_be_found
    @mailmap.write("<commit@email.xx>\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_name_with_email_should_not_be_found
    @mailmap.write("<commit@email.xx> Proper Name\n")

    expected = ["<commit@email.xx>\n", '', 0]
    actual = check_mailmap('<commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_name_with_name_email_should_not_be_found
    @mailmap.write("<commit@email.xx> Proper Name\n")

    expected = ["Commit Name <commit@email.xx>\n", '', 0]
    actual = check_mailmap('Commit Name <commit@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_name_with_wrong_email_should_not_be_found
    @mailmap.write("<commit@email.xx> Proper Name\n")

    expected = ["<wrong@email.xx>\n", '', 0]
    actual = check_mailmap('<wrong@email.xx>')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_name_with_invalid_empty_should_not_be_found
    @mailmap.write("<commit@email.xx> Proper Name\n")

    expected = ['', "fatal: unable to parse contact: \n", 128]
    actual = check_mailmap('')

    assert_equal(expected, actual)
  end

  def test_check_mailmap_on_invalid_email_name_with_invalid_name_should_not_be_found
    @mailmap.write("<commit@email.xx> Proper Name\n")

    expected = ['', "fatal: unable to parse contact: Commit Name\n", 128]
    actual = check_mailmap('Commit Name')

    assert_equal(expected, actual)
  end

  private

  def check_mailmap(*args)
    @mailmap.close
    command = [
      RbConfig.ruby,
      '-r',
      File.expand_path('../../simplecov_spawn.rb', __FILE__),
      File.expand_path('../../../exe/check-mailmap', __FILE__),
      '-f', @mailmap.path
    ] + args
    stdout, stderr, status = Open3.capture3(*command)
    [stdout, stderr, status.exitstatus]
  end
end
