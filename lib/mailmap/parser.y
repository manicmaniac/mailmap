# vim:ft=racc:sw=2:et

class Parser
rule
  entries : entry
            { result = val[0] ? [val[0]] : [] }
          | entries entry
            { result << val[1] }
          |
            { result = [] }

  entry : NAME EMAIL NAME EMAIL newline
          { result = Entry.new(val[0], val[1], val[2], val[3]) }
        | NAME EMAIL EMAIL newline
          { result = Entry.new(val[0], val[1], nil, val[2]) }
        | NAME EMAIL newline
          { result = Entry.new(val[0], nil, nil, val[1]) }
        | EMAIL NAME EMAIL newline
          { result = Entry.new(nil, val[0], val[1], val[2]) }
        | EMAIL EMAIL newline
          { result = Entry.new(nil, val[0], nil, val[1]) }
        | newline
          { result = nil }

  newline : NEWLINE
    { @line_number += 1 }

---- header
require 'mailmap/lexer'

module Mailmap
  Entry = Struct.new(
    :proper_name,
    :proper_email,
    :commit_name,
    :commit_email
  )

  # This exception is raised if a parser error occurs.
  class ParserError < StandardError
  end

  # A parser for .mailmap format
---- inner

# @param string [String] the string in .mailmap format
# @return [Array<Entry>]
# @raise ParserError
def parse(string)
  @line_number = 1
  @tokens = Lexer.new(string).to_enum
  do_parse
end

def next_token
  @tokens.next
end

def on_error(*args)
  raise ParserError, "Invalid format at line #{@line_number}"
end

---- footer
end
