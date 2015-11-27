require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Meaning::Graph

  ::Skylab::TanMan::TestSupport::Models::Meaning[ TS_ = self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

  module InstanceMethods

    def graph_from * s_pair_a

      Home_::Models_::Meaning::Graph__.new(
        Home_::Callback_::Stream.via_nonsparse_array( s_pair_a ) do | s, s_ |
          Home_::Models_::Meaning.new s, s_
        end )
    end
  end
end
