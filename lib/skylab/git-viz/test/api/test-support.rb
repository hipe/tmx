require_relative '../test-support'

module Skylab::GitViz::TestSupport::API

  ::Skylab::GitViz::TestSupport[ TS__ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  module InstanceMethods

    def invoke_API * x_a
      @emit_spy = bld_emit_spy
      x_a[ 1, 0 ] = [ :listener, bld_listener_around( @emit_spy ) ]
      x_a.unshift :API_action_locator_x
      @result = GitViz_::API.invoke_with_iambic x_a ; nil
    end

    def bld_emit_spy
      GitViz_::Callback_.test_support.call_digraph_listeners_spy(
        :debug_IO, debug_IO,
        :do_debug_proc, -> { do_debug } )
    end

    def build_baked_em_a
      es = @emit_spy ; @emit_spy = :_spent_
      es.delete_emission_a
    end

    def bld_listener_around emitter
      Common_shape_listener__[].new emitter
    end

    Common_shape_listener__ = GitViz_::Lib_::Memoize[ -> do
      GitViz_::Callback_::Selective_listener.
        make_via_didactic_matrix [ :info ], [ :line ]
    end ]

    def expect_result_for_failure  # #hook-out
      @result.should eql false
    end
  end
end
