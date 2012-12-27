require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Meaning::Graph
  ::Skylab::TanMan::TestSupport::Models::DotFile::Meaning[ self ]

  include CONSTANTS

  extend TestSupport::Quickie


  module InstanceMethods
    def graph_from a_a
      enum = [ ]
      g = TanMan::Models::DotFile::Meaning::Graph.new nil, enum
      a_a.each do |name, value|
        enum.push new_meaning( name, value )
      end
      g
    end

    def _meaning name_string # you *must* use this before the graph indexes
      graph.send(:list).detect { |m| name_string == m.name } # itself
    end

    meaning_class = TanMan::Models::DotFile::Meaning
    define_method :new_meaning do |name, value|
      meaning_class.new nil, name, value
    end
  end
end
