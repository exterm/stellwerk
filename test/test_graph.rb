# frozen_string_literal: true

require "test_helper"
require "stellwerk/graph"

class TestGraph < Minitest::Test
  def test_build_flat_maps_extractor_results_over_collected_files
    root = "/tmp/app"
    file_a = Pathname.new("/tmp/app/a.rb")
    file_b = Pathname.new("/tmp/app/b.rb")
    ref_a = Object.new
    ref_b = Object.new

    collector = mock("collector")
    collector.expects(:call).returns([file_a, file_b])
    Stellwerk::SourceFileCollector.expects(:new).with(instance_of(Pathname)).returns(collector)

    extractor = mock("extractor")
    extractor.expects(:references_from_file).with(file_a).returns([ref_a])
    extractor.expects(:references_from_file).with(file_b).returns([ref_b])
    ReferenceExtractor::Extractor.expects(:new).returns(extractor)

    edgelist = Stellwerk::Graph.new(root, autoloaders: [], workers: 1).build

    assert_equal [ref_a, ref_b], edgelist
  end
end
