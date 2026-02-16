# frozen_string_literal: true

module Stellwerk
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("../tasks/stellwerk.rake", __dir__)
    end
  end
end
