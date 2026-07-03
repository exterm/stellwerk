# frozen_string_literal: true

namespace :stellwerk do
  task check: :environment do
    autoloaders = [Rails.autoloaders.main, Rails.autoloaders.once].compact

    violations = Stellwerk::Commands::Check.new(Rails.root, autoloaders: autoloaders).run

    exit 1 if violations.any?
  end

  task :check_simple do
    violations = Stellwerk::Commands::Check.new(Dir.pwd).run

    exit 1 if violations.any?
  end

  task graph: :environment do
    autoloaders = [Rails.autoloaders.main, Rails.autoloaders.once].compact

    Stellwerk::Commands::Graph.new(Rails.root, autoloaders: autoloaders).run
  end
end
