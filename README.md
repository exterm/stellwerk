# Stellwerk

Stellwerk is a Ruby gem that helps enforce architectural rules in Ruby on Rails applications. It analyzes the codebase and identifies violations of architectural constraints specified in `stellwerk.yml`.

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

You can also run a simpler check without booting the app. Stellwerk will not use the app's autoloaders and instead emulate a default Rails setup.
This is useful for testing or as a workaround when Stellwerk doesn't understand your autoloader setup (please report a bug in that case).
There can be false positives with this mode for custom autoloader configurations.

```bash
bin/rails stellwerk:check_simple
```

### Querying the dependency graph

Stellwerk can dump the application's dependency graph as TSV so tools (including AI coding
agents) can query it. The task writes the graph to stdout; pipe it to a file:

```bash
bin/rails stellwerk:graph > tmp/stellwerk_graph.tsv
```

Each row is one constant reference with columns `from`, `line`, `to`, `to_location`. Query it
with `awk`:

```bash
# What depends on a file (impact analysis)?
awk -F'\t' '$4=="app/models/order.rb"' tmp/stellwerk_graph.tsv

# What does a file depend on?
awk -F'\t' '$1=="app/services/checkout.rb"' tmp/stellwerk_graph.tsv
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

In this scenario,
- all controllers, jobs and models can depend on stuff in `lib`
- controllers can additionally depend on jobs and models
- code in `lib` can not depend on controllers, jobs or models and jobs or models can not depend on controllers
- everything not mentioned (e.g. `app/services`) can depend on anything else and be depended on by anything else

##### Named stacks and exceptions

Instead of a single list, you can define multiple named layer stacks, each enforced independently. A stack may declare `exceptions`: specific `from`/`to` references that are allowed despite the layering. The `to` is a constant name, matched ignoring any leading `::` (so both `OcppMessage` and `::OcppMessage` work).

```yaml
rules:
  layers:
    app_layering:
      stack:
        - app/controllers
        - [ app/jobs, app/models ]
        - lib
    pipeline_boundary:
      stack:
        - engines/pipeline
        - app
      exceptions:
        - from: app/services/csms_health.rb
          to: OcppMessage
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
