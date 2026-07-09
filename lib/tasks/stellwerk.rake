# frozen_string_literal: true

namespace :stellwerk do
  desc "Check the application against the architectural rules in stellwerk.yml"
  task check: :environment do
    autoloaders = [Rails.autoloaders.main, Rails.autoloaders.once].compact

    violations = Stellwerk::Commands::Check.new(Rails.root, autoloaders: autoloaders).run

    exit 1 if violations.any?
  end

  desc "Check architectural rules without booting the app (can miss or invent references)"
  task :check_simple do
    violations = Stellwerk::Commands::Check.new(Dir.pwd).run

    exit 1 if violations.any?
  end

  desc "Dump the constant reference graph as TSV on stdout"
  task graph: :environment do
    autoloaders = [Rails.autoloaders.main, Rails.autoloaders.once].compact

    Stellwerk::Commands::Graph.new(Rails.root, autoloaders: autoloaders).run
  end
end
