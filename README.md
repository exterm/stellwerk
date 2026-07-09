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
For custom autoloader configurations this mode can both miss references and report ones that don't exist.

```bash
bin/rails stellwerk:check_simple
```

### Querying the dependency graph

Stellwerk can dump the application's dependency graph as TSV so tools (including AI coding
agents) can query it. The task writes the graph to stdout; pipe it to a file:

```bash
bin/rails stellwerk:graph > tmp/stellwerk_graph.tsv
```

Each row is one constant reference with columns `from`, `line`, `to`, `to_location`. A file that
references the same constant on ten lines produces ten rows, so deduplicate when you want files
rather than reference sites:

```bash
# What depends on a file (impact analysis)?
awk -F'\t' '$4=="app/models/order.rb" {print $1}' tmp/stellwerk_graph.tsv | sort -u

# What does a file depend on?
awk -F'\t' '$1=="app/services/checkout.rb" {print $4}' tmp/stellwerk_graph.tsv | sort -u
```

Drop the `{print}` and the pipe to see every reference site with its line number.

The graph only contains constants that the autoloaders can resolve. Constants referenced as
strings (`"MyJob".constantize`, `config.some_class_name = "MyClass"`, job classes named in
`config/recurring.yml`) produce no edges, and neither do route-to-controller mappings
(`resources :orders`). A file with no inbound edges is therefore a dead code *candidate*, not
proof.

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
