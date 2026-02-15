# Stellwerk

Stellwerk is a Ruby gem that helps you enforce architectural rules in your Ruby on Rails application. It analyzes your codebase and identifies violations of architectural constraints you specify.

## Name

The name "Stellwerk" is derived from the German word for "signal station" in a railway context. It keeps your Rails on track!

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add stellwerk
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install stellwerk
```

## Usage

Run the check task in your Rails app:

```bash
bin/rails stellwerk:check
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Publishing to RubyGems

1. Update the version in `lib/stellwerk/version.rb`. Push / merge to main.
2. `rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/exterm/stellwerk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/exterm/stellwerk/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stellwerk project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/exterm/stellwerk/blob/main/CODE_OF_CONDUCT.md).
