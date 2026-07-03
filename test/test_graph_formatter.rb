# frozen_string_literal: true

require "test_helper"
require "stellwerk/graph_formatter"
require "stringio"

class TestGraphFormatter < Minitest::Test
  include FakeReferenceBuilder

  def test_write_emits_header_then_one_tab_separated_row_per_edge
    edgelist = [
      ref(from: "app/services/checkout.rb", line: 8, to: "PaymentGateway", to_location: "lib/payment_gateway.rb"),
      ref(from: "app/controllers/orders_controller.rb", line: 12, to: "Order", to_location: "app/models/order.rb")
    ]

    io = StringIO.new
    Stellwerk::GraphFormatter.new(edgelist).write(io)

    assert_equal <<~TSV, io.string
      from\tline\tto\tto_location
      app/services/checkout.rb\t8\tPaymentGateway\tlib/payment_gateway.rb
      app/controllers/orders_controller.rb\t12\tOrder\tapp/models/order.rb
    TSV
  end

  def test_write_emits_only_the_header_for_an_empty_edgelist
    io = StringIO.new
    Stellwerk::GraphFormatter.new([]).write(io)

    assert_equal "from\tline\tto\tto_location\n", io.string
  end
end
