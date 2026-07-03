# frozen_string_literal: true

require "pathname"

require "stellwerk/graph"
require "stellwerk/graph_formatter"

module Stellwerk
  module Commands
    class Graph
      def initialize(root_path, autoloaders:, out: $stdout, err: $stderr, graph: nil)
        @root_path = Pathname.new(root_path)
        @autoloaders = autoloaders
        @out = out
        @err = err
        @graph = graph || Stellwerk::Graph.new(@root_path, autoloaders: @autoloaders)
      end

      def run
        @err.puts "running graph extraction..."
        edgelist = @graph.build
        @err.puts "extracted #{edgelist.length} references"

        GraphFormatter.new(edgelist).write(@out)

        print_recipes
      end

      private

      def print_recipes
        @err.puts "query it (pipe stdout to a file first, e.g. > tmp/stellwerk_graph.tsv):"
        @err.puts "  what depends on X:  awk -F'\\t' '$4==\"path/to/file.rb\"' tmp/stellwerk_graph.tsv"
        @err.puts "  what X depends on:  awk -F'\\t' '$1==\"path/to/file.rb\"' tmp/stellwerk_graph.tsv"
      end
    end
  end
end
