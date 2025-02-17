# mailmap

[![Test](https://github.com/manicmaniac/mailmap/actions/workflows/main.yml/badge.svg)](https://github.com/manicmaniac/mailmap/actions/workflows/main.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/d43e7ca25cb834a37a99/maintainability)](https://codeclimate.com/github/manicmaniac/mailmap/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d43e7ca25cb834a37a99/test_coverage)](https://codeclimate.com/github/manicmaniac/mailmap/test_coverage)
[![Gem Version](https://badge.fury.io/rb/mailmap.svg)](https://rubygems.org/gems/mailmap)

Pure Ruby implementation of [Git mailmap](https://git-scm.com/docs/gitmailmap).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mailmap'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mailmap

## Usage

```ruby
require 'mailmap'

# Load .mailmap file
mailmap = Mailmap::Map.load('.mailmap')

# Parse string
mailmap = Mailmap::Map.parse('Proper Name <proper@example.com> <commit@example.com>')

# Parse string with optional filename
mailmap = Mailmap::Map.parse('Proper Name <proper@example.com> <commit@example.com>', '.mailmap')

# Equivalent to git check-mailmap 'Commit Name' 'commit@example.com'
mailmap.resolve('Commit Name', 'commit@example.com') # => ['Proper Name', 'proper@example.com']

# Equivalent to git check-mailmap 'commit@example.com'
mailmap.resolve(nil, 'commit@example.com') # => [nil, 'proper@example.com']

# Similar to `Map#resolve` but returns nil if not found
mailmap.lookup('Nonexistent Name', 'nonexistent@example.com') #=> nil
```

See [API reference](https://www.rubydoc.info/gems/mailmap) for more information.

## Command Line

This gem includes command-line tool named `check-mailmap`.
It is pure Ruby implementation of [`git check-mailmap`](https://git-scm.com/docs/git-check-mailmap) and is intended to be a drop-in replacement for `git check-mailmap`.

```sh
$ bundle exec check-mailmap --help
usage: check-mailmap [<options>] <contact>...
    -f, --file=FILE                  path to the .mailmap file (default: ./.mailmap)
        --stdin                      also read contacts from stdin
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/manicmaniac/mailmap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
