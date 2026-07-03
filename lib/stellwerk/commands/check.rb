require "pathname"
require "zeitwerk"

require "stellwerk/config"
require "stellwerk/printer"
require "stellwerk/graph"

module Stellwerk
  module Commands
    class Check
      def initialize(root_path, autoloaders: nil)
        @root_path = Pathname.new(root_path)
        @autoloaders = autoloaders || fake_autoloaders
      end

      def run
        puts "running check..."
        config = Stellwerk::Config.new(@root_path.join("stellwerk.yml"))

        edgelist = Stellwerk::Graph.new(@root_path, autoloaders: @autoloaders).build
        puts "extracted #{edgelist.length} references"

        # check rules against graph, collect violations
        puts "checking rules..."
        violations = config.rules.flat_map do |rule|
          rule.find_violations(edgelist)
        end

        Stellwerk::Printer.new(violations).print

        violations
      end

      private

      def fake_autoloaders
        loader = Zeitwerk::Loader.new
        @root_path.join("app").each_child { |child| loader.push_dir(child) }
        loader.push_dir(@root_path.join("lib"))
        loader.setup
        [loader]
      end
    end
  end
end
