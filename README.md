# ShellStrike
[![Build Status](https://travis-ci.org/xtrasimplicity/shell-strike.svg?branch=master)](https://travis-ci.org/xtrasimplicity/shell-strike)
[![Coverage Status](https://coveralls.io/repos/github/xtrasimplicity/shell-strike/badge.svg?branch=master)](https://coveralls.io/github/xtrasimplicity/shell-strike?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/f66cd28d67eb40caf879/maintainability)](https://codeclimate.com/github/xtrasimplicity/shell-strike/maintainability)
[![Read the Docs](https://img.shields.io/readthedocs/pip.svg)](http://www.rubydoc.info/github/xtrasimplicity/shell-strike/master)

A simple ruby gem to automatically identify valid SSH credentials for a server using custom username and password dictionaries.


This gem is intended to be used for educational purposes, and was written to assist with quickly identifying credential combinations for poorly documented internal servers. This gem is intended to be used against servers that you are authorised to 'attack' and the developer takes no responsibility for any issues which may arise due to misuse of this gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shell_strike'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shell_strike

## Usage
Create a new instance of ShellStrike, passing in an array of `ShellStrike::Host` objects, an array of usernames and an array of passwords. i.e.

```ruby
hosts = [
  ShellStrike::Host.new('192.168.1.100'),
  ShellStrike::Host.new('192.168.1.101')
]

usernames = ['admin', 'root']
passwords = ['password', 'letmein']

shell_strike = ShellStrike.new(hosts, usernames, passwords)

shell_strike.identify_credentials!
```

Access identified credentials using `shell_strike.identified_credentials`.

## Events
ShellStrike includes numerous events which users can consume on each instance of ShellStrike, like this:

```ruby
 shell_strike = ShellStrike.new(...)
 shell_strike.identify_credentials!
 
 shell_strike.on(:credentials_identified) do |host, username, password|
  puts "Success! #{username} / #{password} can be used to login to #{host}."
 end
```

The following events are available:
  * `:credentials_identified` => Triggered when valid credentials have been identified. Yields blocks supplied by listeners with three arguments: (1) The host object, (2) the valid username, and (3) the valid password.
  * `:credentials_failed` => Triggered when credential validation fails. Yields blocks supplied by listeners with three arguments: (1) The host object, (2) the invalid username, and (3) the invalid password.

## TODO
- Add support for user-defineable SSH arguments such as KexAlgorithms and key-based auth.


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xtrasimplicity/shell_strike. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ShellStrike project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/xtrasimplicity/shell_strike/blob/master/CODE_OF_CONDUCT.md).
