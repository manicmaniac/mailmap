# frozen_string_literal: true

require 'forwardable'
require 'strscan'

module Mailmap
  # This exception is raised if a parser error occurs.
  class ParserError < StandardError
  end

  # A Map represents a .mailmap file.
  class Map
    extend Forwardable

    def_delegators :each, *Enumerable.instance_methods(false)

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
      @map = Hash.new { |h, k| h[k] = {} }
      parse(string)
    end

    def each
      return enum_for(:each) unless block_given?

      @map.each do |commit_email, entries_by_commit_name|
        entries_by_commit_name.each do |commit_name, (proper_name, proper_email)|
          yield [proper_name, proper_email, commit_name, commit_email]
        end
      end
      self
    end

    # Look up the person's canonical name and email address.
    # If found, return them; otherwise return nil.
    #
    # @param commit_name_or_nil [String, nil] the name in commit or nil
    # @param commit_email [String] the name in commit
    # @return [Array<String>] if found, a pair of proper name and email or nil
    # @return [nil] if not found
    def lookup(commit_name_or_nil, commit_email)
      commit_name = commit_name_or_nil&.downcase
      commit_email = commit_email.downcase
      hash = @map[commit_email]
      hash[commit_name] || hash[nil]
    end

    # Like `git-check-mailmap` command, look up the person's canonical name and email address.
    # If found, return them; otherwise return the input as-is.
    #
    # @param commit_name_or_nil [String, nil] the name in commit or nil
    # @param commit_email [String] the email in commit
    # @return [Array<String>] a pair of proper name and email
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
      any? do |(proper_name, _proper_email, commit_name, _commit_email)|
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
      any? do |(_proper_name, proper_email, _commit_name, commit_email)|
        proper_email&.downcase == email || commit_email == email
      end
    end

    private

    def parse(string)
      string.each_line.with_index(1) do |line, line_number|
        next if line.start_with?('#')

        parse_name_and_email(line, line_number)
      end
    end

    def parse_name_and_email(line, line_number) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      names = []
      emails = []
      scanner = StringScanner.new(line)
      2.times do
        scanner.skip(/\s+/)
        scanner.scan(/[^<]+/).then { |s| names << s.rstrip if s }
        scanner.skip(/</)
        scanner.scan(/[^>]+/).then { |s| emails << s if s }
        scanner.skip(/>/)
      end
      raise ParserError, "Missing commit email at line #{line_number}" if emails.empty?

      commit_email = emails.pop&.downcase
      proper_email = emails.pop
      proper_name = names.shift
      commit_name = names.shift&.downcase
      @map[commit_email][commit_name] = [proper_name, proper_email]
    end
  end
end
