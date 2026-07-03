# frozen_string_literal: true

require "test_helper"
require "stellwerk/commands/graph"
require "stringio"

class TestCommandsGraph < Minitest::Test
  include FakeReferenceBuilder

  def build_command(edgelist, out:, err:)
    fake_graph = mock("graph")
    fake_graph.stubs(:build).returns(edgelist)
    Stellwerk::Commands::Graph.new("/tmp/app", autoloaders: [], out: out, err: err, graph: fake_graph)
  end

  def test_run_writes_tsv_to_the_data_io
    edgelist = [ref(from: "app/services/checkout.rb", line: 8, to: "PaymentGateway", to_location: "lib/payment_gateway.rb")]
    out = StringIO.new
    err = StringIO.new

    build_command(edgelist, out: out, err: err).run

    assert_equal <<~TSV, out.string
      from\tline\tto\tto_location
      app/services/checkout.rb\t8\tPaymentGateway\tlib/payment_gateway.rb
    TSV
  end

  def test_run_writes_diagnostics_and_recipes_only_to_the_error_io
    edgelist = [ref(from: "a.rb", line: 1, to: "B", to_location: "b.rb")]
    out = StringIO.new
    err = StringIO.new

    build_command(edgelist, out: out, err: err).run

    assert_includes err.string, "extracted 1 references"
    assert_includes err.string, "awk -F"
    refute_includes out.string, "extracted"
    refute_includes out.string, "awk"
  end

  def test_run_returns_the_edgelist
    edgelist = [ref(from: "a.rb", line: 1, to: "B", to_location: "b.rb")]

    result = build_command(edgelist, out: StringIO.new, err: StringIO.new).run

    assert_equal edgelist, result
  end
end
