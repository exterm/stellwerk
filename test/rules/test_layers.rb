# frozen_string_literal: true

require "test_helper"
require "stellwerk/rules/layers"

class TestRulesLayers < Minitest::Test
  FakeConstant = Struct.new(:location)
  FakeReference = Struct.new(:relative_path, :constant)

  def reference(from:, to:)
    FakeReference.new(from, FakeConstant.new(to))
  end

  def test_initialize_raises_on_overlapping_layers
    assert_raises(Stellwerk::Rules::Layers::InvalidLayersSpec) do
      Stellwerk::Rules::Layers.new(["app/models", "app/models"])
    end
  end

  def test_initialize_raises_when_no_layers_exist
    assert_raises(Stellwerk::Rules::Layers::InvalidLayersSpec) do
      Stellwerk::Rules::Layers.new([])
    end
  end

  def test_initialize_raises_when_empty_layer_exists
    assert_raises(Stellwerk::Rules::Layers::InvalidLayersSpec) do
      Stellwerk::Rules::Layers.new([[], "app/models"])
    end
  end

  def test_stack_filter_graph_only_keeps_references_between_known_components
    stack = Stellwerk::Rules::Layers::Stack.new(["app/models", "app/services"], [])

    r1 = reference(from: "app/models/user.rb", to: "app/services/do_thing.rb")
    r2 = reference(from: "lib/foo.rb", to: "app/models/user.rb")
    r3 = reference(from: "app/models/user.rb", to: "lib/foo.rb")

    assert_equal [r1], stack.filter_graph([r1, r2, r3])
  end

  def test_find_violations_flags_references_from_lower_to_higher_layer
    rule = Stellwerk::Rules::Layers.new(["app/services", "app/models"])

    bad = reference(from: "app/models/user.rb", to: "app/services/do_thing.rb")
    ok = reference(from: "app/services/do_thing.rb", to: "app/models/user.rb")

    violations = rule.find_violations([ok, bad])

    assert_equal 1, violations.size
    assert_equal :layers, violations.first.rule
    assert_equal bad, violations.first.reference
  end

  # Name-carrying reference, needed for exception matching (matches on constant name).
  NamedConstant = Struct.new(:name, :location)
  NamedReference = Struct.new(:relative_path, :constant)

  def named_reference(from:, to_name:, to_location:)
    NamedReference.new(from, NamedConstant.new(to_name, to_location))
  end

  def test_multiple_named_stacks_are_all_enforced
    rule = Stellwerk::Rules::Layers.new(
      "app_layering" => {"stack" => ["app/services", "app/models"]},
      "pipeline_boundary" => {"stack" => ["engines/pipeline", "app"]}
    )

    app_layering_violation = reference(from: "app/models/user.rb", to: "app/services/do_thing.rb")
    pipeline_violation = reference(from: "app/services/x.rb", to: "engines/pipeline/app/models/ocpp_message.rb")
    ok = reference(from: "engines/pipeline/app/models/ocpp_message.rb", to: "app/models/user.rb")

    violations = rule.find_violations([app_layering_violation, pipeline_violation, ok])

    assert_equal [app_layering_violation, pipeline_violation].sort_by(&:to_s),
      violations.map(&:reference).sort_by(&:to_s)
  end

  def test_exceptions_suppress_a_specific_from_to_reference
    rule = Stellwerk::Rules::Layers.new(
      "pipeline_boundary" => {
        "stack" => ["engines/pipeline", "app"],
        "exceptions" => [{"from" => "app/services/csms_health.rb", "to" => "OcppMessage"}]
      }
    )

    excepted = named_reference(
      from: "app/services/csms_health.rb",
      to_name: "OcppMessage",
      to_location: "engines/pipeline/app/models/ocpp_message.rb"
    )
    still_flagged = named_reference(
      from: "app/services/other.rb",
      to_name: "OcppMessage",
      to_location: "engines/pipeline/app/models/ocpp_message.rb"
    )

    violations = rule.find_violations([excepted, still_flagged])

    assert_equal [still_flagged], violations.map(&:reference)
  end

  def test_legacy_array_config_still_works_without_exceptions
    rule = Stellwerk::Rules::Layers.new(["app/services", "app/models"])

    bad = reference(from: "app/models/user.rb", to: "app/services/do_thing.rb")

    assert_equal [bad], rule.find_violations([bad]).map(&:reference)
  end
end
