module Stellwerk
  class Printer
    def initialize(violations)
      @violations = violations
    end

    def print
      puts "\nFound #{@violations.length} violations."

      @violations.group_by { |violation| violation.rule }.each do |rule, violations|
        puts "#{rule.name.titleize} rule violations:"
        violations.each do |violation|
          puts "  " + format_reference(violation.reference)
        end
      end
    end

    private

    def format_reference(reference)
      source = "#{reference.relative_path}:#{reference.source_location.line}"
      target = "#{reference.constant.name}, defined in #{reference.constant.location}"
      "#{source} refers to #{target}"
    end
  end
end
