require "active_support/core_ext/string"

module Stellwerk
  class Config
    class UnknownRule < StandardError; end

    attr_reader :rules

    def initialize(filepath)
      config = YAML.load_file(filepath)

      @rules = initialize_rules(config["rules"])
    end

    def initialize_rules(rules_config)
      rules_config.map do |rule_name, rule_config|
        begin
          require "stellwerk/rules/#{rule_name}"
          rule_class = ("Stellwerk::Rules::" + rule_name.camelize).constantize
        rescue LoadError, NameError
          raise(UnknownRule, "Unknown rule: #{rule_name}")
        end

        rule_class.new(rule_config)
      end
    end
  end
end
