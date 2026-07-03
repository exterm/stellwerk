require "pathname"

require "stellwerk/violation"

module Stellwerk
  module Rules
    class Layers
      class InvalidLayersSpec < RuntimeError; end

      # Accepts either:
      #   - an Array (one stack, no exceptions) — legacy form, backward compatible
      #   - a Hash of name => { "stack" => [...], "exceptions" => [...] }
      def initialize(rule_spec)
        @stacks =
          if rule_spec.is_a?(Array)
            [Stack.new(rule_spec, [])]
          else
            rule_spec.map do |_name, stack_spec|
              Stack.new(stack_spec.fetch("stack"), stack_spec["exceptions"] || [])
            end
          end
      end

      def find_violations(reference_graph)
        @stacks.flat_map { |stack| stack.find_violations(reference_graph) }
      end

      # One ordered layer stack plus its exception allowlist. Lower layers
      # (higher index) may not reference higher layers (lower index).
      class Stack
        def initialize(layers_spec, exceptions_spec)
          @layers = layers_spec.map { |layer| Array(layer).map { |path_string| Pathname.new(path_string) } }
          @exceptions = exceptions_spec.map { |exception| [exception.fetch("from"), exception.fetch("to")] }
          validate_layers!
        end

        def find_violations(reference_graph)
          filter_graph(reference_graph).filter_map do |reference|
            next if excepted?(reference)

            if layer_index(reference.relative_path) > layer_index(reference.constant.location)
              Violation.new(:layers, reference)
            end
          end
        end

        def filter_graph(reference_graph)
          reference_graph.select do |reference|
            all_components.any? { |component| path_in_component?(reference.relative_path, component) } &&
              all_components.any? { |component| path_in_component?(reference.constant.location, component) }
          end
        end

        private

        def excepted?(reference)
          @exceptions.any? do |from, to|
            reference.relative_path.to_s == from &&
              reference.constant.name.delete_prefix("::") == to.delete_prefix("::")
          end
        end

        def all_components
          @layers.flatten
        end

        def path_in_component?(path, component)
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
end
