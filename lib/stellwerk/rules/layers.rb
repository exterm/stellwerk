require "pathname"

require "stellwerk/violation"

module Stellwerk
  module Rules
    class Layers
      class InvalidLayersSpec < RuntimeError; end

      def initialize(rule_spec)
        @layers = rule_spec.map { |layer| Array(layer).map { |path_string| Pathname.new(path_string) } }
        validate_layers!
      end

      def find_violations(reference_graph)
        relevant_graph = filter_graph(reference_graph)

        relevant_graph.map do |reference|
          # TO DO: violations should include some rule specific violation context
          # e.g. from layer and to layer
          if layer_index(reference.relative_path) > layer_index(reference.constant.location)
            Violation.new(:layers, reference)
          end
        end.compact
      end

      def filter_graph(reference_graph)
        reference_graph.select do |reference|
          all_components.any? { |component| path_in_component?(reference.relative_path, component) } &&
            all_components.any? { |component| path_in_component?(reference.constant.location, component) }
        end
      end

      def all_components
        @layers.flatten
      end

      def path_in_component?(path, component)
        # TO DO: Find out whether we can use Pathname methods to determine whether one path contains another
        component_dirname = component.to_s
        component_dirname += "/" unless component.to_s.end_with?("/")
        path.to_s.start_with?(component_dirname)
      end

      def layer_index(file_path)
        @layers.index do |components|
          components.any? { |component| path_in_component?(file_path, component) }
        end
      end

      def validate_layers!
        raise InvalidLayersSpec, "Overlapping layers" if all_components.count != all_components.uniq.count
        raise InvalidLayersSpec, "No layers exist" if @layers.empty?
        raise InvalidLayersSpec, "Empty layers exist" if @layers.any?(&:empty?)
      end
    end
  end
end
