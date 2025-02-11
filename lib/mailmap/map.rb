# frozen_string_literal: true

require 'mailmap/parser'
require 'strscan'

module Mailmap
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
      Parser.new.parse(string).each do |entry|
        @map[entry.commit_email.downcase][entry.commit_name&.downcase] = [entry.proper_name, entry.proper_email]
      end
    end
  end
end
