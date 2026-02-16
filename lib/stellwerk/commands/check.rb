require "pathname"
require "reference_extractor"
require "zeitwerk"
require "parallel"

require "stellwerk/config"
require "stellwerk/printer"

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

        # build graph using reference_extractor
        extractor = ReferenceExtractor::Extractor.new(
          autoloaders: @autoloaders,
          root_path: @root_path
        )

        all_files = @root_path.find
          .select { |path| path.to_s.end_with?(".rb") }
          .reject { |path| path.relative_path_from(@root_path).to_s.start_with?("db/") }
        puts "collected #{all_files.length} files"

        before = Time.now
        edgelist = Parallel.flat_map(all_files, in_processes: Parallel.processor_count - 1) do |file|
          extractor.references_from_file(file)
        end
        puts "extracted #{edgelist.length} references in #{(Time.now - before).round(2)} seconds"

        # check rules against graph, collect violations
        puts "checking rules..."
        violations = config.rules.flat_map do |rule|
          rule.find_violations(edgelist)
        end

        Stellwerk::Printer.new(violations).print
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
