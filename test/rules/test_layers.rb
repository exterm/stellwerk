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

  def test_filter_graph_only_keeps_references_between_known_components
    rule = Stellwerk::Rules::Layers.new(["app/models", "app/services"])

    r1 = reference(from: "app/models/user.rb", to: "app/services/do_thing.rb")
    r2 = reference(from: "lib/foo.rb", to: "app/models/user.rb")
    r3 = reference(from: "app/models/user.rb", to: "lib/foo.rb")

    assert_equal [r1], rule.filter_graph([r1, r2, r3])
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
end
