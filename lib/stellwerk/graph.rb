# frozen_string_literal: true

require "pathname"
require "reference_extractor"
require "parallel"

require "stellwerk/source_file_collector"

module Stellwerk
  class Graph
    def initialize(root_path, autoloaders:, workers: default_workers)
      @root_path = Pathname.new(root_path)
      @autoloaders = autoloaders
      @workers = workers
    end

    def build
      extractor = ReferenceExtractor::Extractor.new(autoloaders: @autoloaders, root_path: @root_path)
      files = SourceFileCollector.new(@root_path).call

      if @workers > 1
        Parallel.flat_map(files, in_processes: @workers) { |file| extractor.references_from_file(file) }
      else
        files.flat_map { |file| extractor.references_from_file(file) }
      end
    end

    private

    def default_workers
      [Parallel.processor_count - 1, 1].max
    end
  end
end
