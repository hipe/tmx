require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Meaning::Graph

  ::Skylab::TanMan::TestSupport::Models::Meaning[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def graph_from a_a
      ea = ::Enumerator.new do |y|
        a_a.each do |name, value|
          y << TanMan::Models::Meaning.new( nil, name, value )
        end
        nil
      end
      TanMan::Models::Meaning::Graph.new nil, ea
    end
  end
end
