# frozen_string_literal: true

require_relative "lib/stellwerk/version"

Gem::Specification.new do |spec|
  spec.name = "stellwerk"
  spec.version = Stellwerk::VERSION
  spec.authors = ["Philip Theus"]
  spec.email = ["philip@simplexity.quest"]

  spec.summary = "Keep your Rails on track by enforcing a rules-based architecture."
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/exterm/stellwerk"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/exterm/stellwerk"
  spec.metadata["changelog_uri"] = "https://github.com/exterm/stellwerk/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "reference_extractor"
  spec.add_dependency "activesupport"
  spec.add_dependency "parallel"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
