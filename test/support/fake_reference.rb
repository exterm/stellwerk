# frozen_string_literal: true

# Shared fixtures mirroring the shape of ReferenceExtractor::Reference that
# GraphFormatter and Commands::Graph consume.
module FakeReferenceBuilder
  FakeLocation = Struct.new(:line)
  FakeConstant = Struct.new(:name, :location)
  FakeReference = Struct.new(:relative_path, :constant, :source_location)

  def ref(from:, line:, to:, to_location:)
    FakeReference.new(from, FakeConstant.new(to, to_location), FakeLocation.new(line))
  end
end
