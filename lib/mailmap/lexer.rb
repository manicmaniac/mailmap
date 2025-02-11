# frozen_string_literal: true

require 'strscan'

module Mailmap
  # A lexer for .mailmap format.
  class Lexer
    include Enumerable

    def initialize(string)
      @scanner = StringScanner.new(string)
    end

    def each # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      return enum_for unless block_given?

      until @scanner.eos?
        case @scanner.peek(1)
        when "\n"
          @scanner.scan(/\n+/)&.then { |s| yield [:NEWLINE, s] }
        when ' ', "\t"
          @scanner.skip(/[ \t]+/)
        when '#'
          @scanner.skip(/[^\n]+/)
        when '<'
          @scanner.scan(/<([^>]*)>/)&.then { |s| yield [:EMAIL, unquote_email(s)] }
        else
          @scanner.scan(/([^\n<#]+)/)&.then { |s| yield [:NAME, s.strip] }
        end
      end
      yield nil
      self
    end

    private

    def unquote_email(email)
      email.delete_prefix('<').delete_suffix('>')
    end
  end
end
