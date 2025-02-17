# frozen_string_literal: true

require 'tempfile'
require 'test_helper'

module Mailmap
  class MapTest < Minitest::Test # rubocop:disable Metrics/ClassLength
    def test_load
      Tempfile.open('mailmap') do |f|
        f.write(<<~MAILMAP)
          Proper Name <commit@email.xx>
        MAILMAP

        assert_kind_of(Map, Map.load(f.path || abort))
      end
    end

    def test_each_with_block_returns_self
      mailmap = Map.parse('')
      result = mailmap.each do
        # Do nothing
      end

      assert_equal(result, mailmap)
    end

    def test_each_without_block_returns_enumerator
      mailmap = Map.parse(<<~MAILMAP)
        Joe R. Developer <joe@example.com>
        Jane Doe <jane@example.com> <jane@laptop.(none)>
        Jane Doe <jane@example.com> <jane@desktop.(none)>
      MAILMAP
      enumerator = mailmap.to_enum

      assert_equal(['Joe R. Developer', nil, nil, 'joe@example.com'], enumerator.next)
      assert_equal(['Jane Doe', 'jane@example.com', nil, 'jane@laptop.(none)'], enumerator.next)
      assert_equal(['Jane Doe', 'jane@example.com', nil, 'jane@desktop.(none)'], enumerator.next)
    end

    def test_each_when_empty
      mailmap = Map.parse('')
      enumerator = mailmap.to_enum

      assert_instance_of(Enumerator, enumerator)
      assert_raises(StopIteration) { enumerator.next }
    end

    def test_count
      mailmap = Map.parse(<<~MAILMAP)
        Joe R. Developer <joe@example.com>
        Jane Doe <jane@example.com> <jane@laptop.(none)>
        Jane Doe <jane@example.com> <jane@desktop.(none)>
      MAILMAP
      assert_equal(3, mailmap.count)
    end

    def test_lookup_without_commit_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', nil], mailmap.lookup(nil, 'commit@email.xx'))
    end

    def test_lookup_with_commit_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', 'proper@email.xx'], mailmap.lookup('Commit Name', 'commit@email.xx'))
    end

    def test_lookup_with_proper_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_nil(mailmap.lookup(nil, 'proper@email.xx'))
    end

    def test_lookup_with_nonexistent_commit_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_nil(mailmap.lookup(nil, 'nonexistent@email.xx'))
    end

    def test_resolve
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', 'commit@email.xx'], mailmap.resolve('Commit Name', 'commit@email.xx'))
    end

    def test_resolve_without_name
      mailmap = Map.parse(<<~MAILMAP)
        <proper@email.xx> <commit@email.xx>
      MAILMAP
      assert_equal([nil, 'proper@email.xx'], mailmap.resolve(nil, 'commit@email.xx'))
    end

    def test_resolve_with_empty_mailmap
      mailmap = Map.parse('')

      assert_equal(['Commit Name', 'commit@email.xx'], mailmap.resolve('Commit Name', 'commit@email.xx'))
    end

    def test_resolve_with_nonexistent_commit_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_equal([nil, 'nonexistent@email.xx'], mailmap.resolve(nil, 'nonexistent@email.xx'))
    end

    def test_include_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert(mailmap.include_name?('Proper Name'))
      assert(mailmap.include_name?('Commit Name'))
    end

    def test_include_name_with_nonexistent_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      refute(mailmap.include_name?('Missing Name'))
    end

    def test_include_name_with_incorrect_case
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert(mailmap.include_name?('proper name'))
      assert(mailmap.include_name?('commit name'))
    end

    def test_include_name_without_names
      mailmap = Map.parse(<<~MAILMAP)
        <proper@email.xx> <commit@email.xx>
      MAILMAP
      refute(mailmap.include_name?('proper name'))
      refute(mailmap.include_name?('commit name'))
    end

    def test_include_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert(mailmap.include_email?('proper@email.xx'))
      assert(mailmap.include_email?('commit@email.xx'))
    end

    def test_include_email_with_nonexistent_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      refute(mailmap.include_email?('missing@email.xx'))
    end

    def test_include_email_with_incorrect_case
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert(mailmap.include_email?('Proper@email.xx'))
      assert(mailmap.include_email?('Commit@email.xx'))
    end

    def test_include_email_without_proper_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      refute(mailmap.include_email?('proper@email.xx'))
      assert(mailmap.include_email?('commit@email.xx'))
    end

    def test_parse_with_empty
      mailmap = Map.parse('')

      assert_empty(mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_comment
      mailmap = Map.parse(<<~MAILMAP)
        # comment
      MAILMAP
      assert_empty(mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_invalid_line
      Map.parse('This line is invalid', '/path/to/mailmap')

      flunk('ParserError was not raised')
    rescue ParserError => e
      assert_equal('Invalid mailmap entry at /path/to/mailmap:1', e.message)
    end

    def test_parse_with_simple_entry
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      expected = {
        'commit@email.xx' => {
          nil => ['Proper Name', nil]
        }
      }

      assert_equal(expected, mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_trailing_comment
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx> # Comment
      MAILMAP
      expected = {
        'commit@email.xx' => {
          nil => ['Proper Name', nil]
        }
      }

      assert_equal(expected, mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_complex_entry_only_emails
      mailmap = Map.parse(<<~MAILMAP)
        <proper@email.xx> <commit@email.xx>
      MAILMAP
      expected = {
        'commit@email.xx' => {
          nil => [nil, 'proper@email.xx']
        }
      }

      assert_equal(expected, mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_complex_entry_name_and_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> <commit@email.xx>
      MAILMAP
      expected = {
        'commit@email.xx' => {
          nil => ['Proper Name', 'proper@email.xx']
        }
      }

      assert_equal(expected, mailmap.instance_variable_get(:@map))
    end

    def test_parse_with_complex_entry_name_and_email_filtering_by_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      expected = {
        'commit@email.xx' => {
          'commit name' => ['Proper Name', 'proper@email.xx']
        }
      }

      assert_equal(expected, mailmap.instance_variable_get(:@map))
    end
  end
end
