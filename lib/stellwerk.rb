# frozen_string_literal: true

require_relative "stellwerk/version"
require_relative "stellwerk/commands/check"
require_relative "stellwerk/commands/graph"

require "rails/railtie"
require_relative "stellwerk/railtie"

module Stellwerk
  class Error < StandardError; end
end
