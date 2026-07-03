# frozen_string_literal: true

module Stellwerk
  class GraphFormatter
    HEADER = %w[from line to to_location].freeze

    def initialize(edgelist)
      @edgelist = edgelist
    end

    def write(io)
      io.puts(HEADER.join("\t"))
      @edgelist.each do |reference|
        io.puts([
          reference.relative_path,
          reference.source_location.line,
          reference.constant.name,
          reference.constant.location
        ].join("\t"))
      end
    end
  end
end
