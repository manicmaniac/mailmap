# frozen_string_literal: true

require 'strscan'

module Mailmap
  # This exception is raised if a parser error occurs.
  class ParserError < StandardError
  end

  # A Map represents a .mailmap file.
  class Map
    include Enumerable

    class << self
      # Load a mailmap file and return Map object.
      #
      # @param path [String] the path to .mailmap file
      # @return [Map]
      def load(path)
        new(File.read(path))
      end

      alias parse new
    end

    # @param string [String] the string in .mailmap format
    def initialize(string)
      # @type ivar @map: Hash[String, Hash[String?, String?]]
      @map = Hash.new { |h, k| h[k] = {} }
      parse(string)
    end

    def each
      return enum_for unless block_given?

      @map.each do |commit_email, entries_by_commit_name|
        entries_by_commit_name.each do |commit_name, (proper_name, proper_email)|
          yield proper_name, proper_email, commit_name, commit_email
        end
      end
      self
    end

    # Look up the person's canonical name and email address.
    # If found, return them; otherwise return nil.
    #
    # @param commit_name_or_nil [String, nil] the name in commit or nil
    # @param commit_email [String] the name in commit
    # @return [(String, String)] if found, a pair of proper name and email
    # @return [(String, nil)] if only proper name is found
    # @return [(nil, String)] if only proper email is found
    # @return [nil] if not found
    def lookup(commit_name_or_nil, commit_email)
      commit_name = commit_name_or_nil&.downcase
      commit_email = commit_email.downcase
      hash = @map[commit_email]
      hash[commit_name] || hash[nil]
    end

    # Like +git-check-mailmap+ command, look up the person's canonical name and email address.
    # If found, return them; otherwise return the input as-is.
    #
    # @param commit_name_or_nil [String, nil] the name in commit or nil
    # @param commit_email [String] the email in commit
    # @return [(String, String)] a pair of proper name and email
    # @return [(nil, String)] if proper name is not found and +commit_name+ is not provided
    def resolve(commit_name_or_nil, commit_email)
      proper_name, proper_email = lookup(commit_name_or_nil, commit_email)
      proper_name ||= commit_name_or_nil
      proper_email ||= commit_email
      [proper_name, proper_email]
    end

    # Return true if the name is defined as either of proper or commit name, otherwise false.
    # The comparison is case-insensitive.
    #
    # @param name [String] the name
    # @return [Boolean]
    def include_name?(name)
      name = name.downcase
      any? do |proper_name, _proper_email, commit_name, _commit_email|
        proper_name&.downcase == name || commit_name == name
      end
    end

    # Return true if the email is defined as either of proper or commit email, otherwise false.
    # The comparison is case-insensitive.
    #
    # @param email [String] the email
    # @return [Boolean]
    def include_email?(email)
      email = email.downcase
      any? do |_proper_name, proper_email, _commit_name, commit_email|
        proper_email&.downcase == email || commit_email == email
      end
    end

    private

    def parse(string)
      string.each_line.with_index(1) do |line, line_number|
        next if line.start_with?('#')

        tokens = tokenize_name_and_email(line)
        proper_name, proper_email, commit_name, commit_email = parse_name_and_email(tokens, line_number)
        @map[commit_email.downcase][commit_name&.downcase] = [proper_name, proper_email]
      end
    end

    def tokenize_name_and_email(line)
      # @type var tokens: Array[[Symbol, String]]
      tokens = []
      scanner = StringScanner.new(line)
      2.times do
        scanner.skip(/\s+/)
        scanner.scan(/[^<]+/)&.then { |s| tokens << [:name, s.rstrip] }
        scanner.scan(/<(.*?)>/)&.then { |s| tokens << [:email, unquote_email(s)] }
        scanner.skip(/\s*#.*$/)
      end
      tokens
    end

    PATTERNS = {
      %i[name email] => %i[proper_name commit_email],
      %i[email email] => %i[proper_email commit_email],
      %i[name email email] => %i[proper_name proper_email commit_email],
      %i[email name email] => %i[proper_email commit_name commit_email],
      %i[name email name email] => %i[proper_name proper_email commit_name commit_email]
    }.freeze
    private_constant :PATTERNS

    def parse_name_and_email(tokens, line_number)
      types = tokens.map(&:first)
      values = tokens.map(&:last)
      fields = PATTERNS[types] or raise ParserError, "Invalid format at line #{line_number}"
      entry = fields.zip(values).to_h
      [entry[:proper_name], entry[:proper_email], entry[:commit_name], entry.fetch(:commit_email)]
    end

    def unquote_email(email)
      email.delete_prefix('<').delete_suffix('>')
    end
  end
end
