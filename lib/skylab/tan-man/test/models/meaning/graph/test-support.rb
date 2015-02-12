require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Meaning::Graph

  ::Skylab::TanMan::TestSupport::Models::Meaning[ TS_ = self ]

  include Constants

  TanMan_ = TanMan_

  extend TestSupport_::Quickie

  module InstanceMethods

    def graph_from * s_pair_a

      TanMan_::Models_::Meaning::Graph__.new(
        TanMan_::Callback_::Stream.via_nonsparse_array( s_pair_a ) do | s, s_ |
          TanMan_::Models_::Meaning.new s, s_
        end )
    end
  end
end
