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
        assert_kind_of(Map, Map.load(f.path))
      end
    end

    def test_each
      mailmap = Map.parse(<<~MAILMAP)
        Joe R. Developer <joe@example.com>
        Jane Doe <jane@example.com> <jane@laptop.(none)>
        Jane Doe <jane@example.com> <jane@desktop.(none)>
      MAILMAP
      enumerator = mailmap.each
      assert_equal(['Joe R. Developer', nil, nil, 'joe@example.com'], enumerator.next)
      assert_equal(['Jane Doe', 'jane@example.com', nil, 'jane@laptop.(none)'], enumerator.next)
      assert_equal(['Jane Doe', 'jane@example.com', nil, 'jane@desktop.(none)'], enumerator.next)
    end

    def test_count
      mailmap = Map.parse(<<~MAILMAP)
        Joe R. Developer <joe@example.com>
        Jane Doe <jane@example.com> <jane@laptop.(none)>
        Jane Doe <jane@example.com> <jane@desktop.(none)>
      MAILMAP
      assert_equal(3, mailmap.count)
    end

    def test_find_without_commit_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', nil], mailmap.find(nil, 'commit@email.xx'))
    end

    def test_find_with_commit_name
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', 'proper@email.xx'], mailmap.find('Commit Name', 'commit@email.xx'))
    end

    def test_find_with_nonexistent_commit_email
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <proper@email.xx> Commit Name <commit@email.xx>
      MAILMAP
      assert_nil(mailmap.find(nil, 'nonexistent@email.xx'))
    end

    def test_resolve
      mailmap = Map.parse(<<~MAILMAP)
        Proper Name <commit@email.xx>
      MAILMAP
      assert_equal(['Proper Name', 'commit@email.xx'], mailmap.resolve('Commit Name', 'commit@email.xx'))
    end

    def test_resolve_with_empty_mailmap
      mailmap = Map.parse('')
      assert_equal(['Commit Name', 'commit@email.xx'], mailmap.resolve('Commit Name', 'commit@email.xx'))
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
      assert_raises(ParserError) do
        Map.parse('This line is invalid')
      end
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
