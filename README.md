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

Create a `stellwerk.yml` in the root of your Rails application that defines at least one [rule](#rules).

Run the check task in your Rails app:

```bash
bin/rails stellwerk:check
```

Run a simpler check without booting `:environment` (uses statically defined Zeitwerk loaders for `app/*` and `lib`) and will probably miss stuff in more complex Rails apps:

```bash
bin/rails stellwerk:check_simple
```

### Rules

Rules are defined in the `stellwerk.yml` file.

#### Layered Architecture

The Layered Architecture rule enforces that files in one layer do not reference files in a layer that is "above" it.

Example configuration with three layers:

```yaml
rules:
  layers:
    - app/controllers
    - [ app/jobs, app/models ]
    - lib
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Publishing to RubyGems

1. Update the version in [`lib/stellwerk/version.rb`](lib/stellwerk/version.rb). Push / merge to main.
2. `rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/exterm/stellwerk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/exterm/stellwerk/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Stellwerk project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/exterm/stellwerk/blob/main/CODE_OF_CONDUCT.md).
