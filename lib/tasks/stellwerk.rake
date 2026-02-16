# frozen_string_literal: true

namespace :stellwerk do
  task check: :environment do
    autoloaders = [Rails.autoloaders.main, Rails.autoloaders.once].compact

    Stellwerk::Commands::Check.new(Rails.root, autoloaders: autoloaders).run
  end

  task :check_simple do
    Stellwerk::Commands::Check.new(Dir.pwd).run
  end
end
