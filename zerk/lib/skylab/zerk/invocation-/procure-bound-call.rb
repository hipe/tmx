module Skylab::Zerk

  module Invocation_

    class Procure_bound_call

      # the entirety of [#027] documents this excessively, as referenced.

      class << self

        def begin__ pvs, fo, & pp
          __begin_empty.__init_initial pvs, fo, & pp
        end

        alias_method :__begin_empty, :new
        undef_method :new
      end  # >>

      # -- initialization

      def __init_initial pvs, fo, & pp

        @formal_operation = fo
        @parameter_value_source = pvs
        @_pp = pp

        @_did_index_big = false
        @_on_unavailable_kn = nil
        @__once_ES = nil
        self
      end

      def on_unavailable_= x
        @_on_unavailable_kn = Callback_::Known_Known[ x ] ; x
      end

      # --

      def execute

        ___prepare

        o = @formal_operation.begin_preparation( & @_oes_p )

        o.bespoke_stream_once = method :__bespoke_stream_once

        o.expanse_stream_once = method :__expanse_stream_once

        o.on_unavailable_ = __on_unavailable

        o.parameter_store = self  # so "as parameter store" below

        o.parameter_value_source = @parameter_value_source

        o.to_bound_call
      end

      def ___prepare

        @_oes_p = method :__on_emission
        @_real_store = @formal_operation.begin_parameter_store( & @_oes_p )
        @_accept_to_real_store = @_real_store.method :accept_parameter_value
        NIL_
      end

      # -- execution support

      def _index_big  # (its callers are defined below it for reasons)

        # since it is a relatively "heavy lift" to build this [#]#scope-set
        # (yet we can't cache it because [#ac-002]#DT3 everything is dynamic),
        # we try to do this only when it is certain that we need to know it
        # (e.g any of its derivatives, i.e #socialist-set or #bespoke-set)
        #
        # create a "diminishing pool" that starts off as the set of all
        # names in the #stated-set.
        #
        # stream along the one or more compound frames that stand below the
        # top item (the formal operation), (in some direction?), and in
        # each such frame, stream along every node of that frame. for this
        # stream of all nodes selected in this manner, do this with each node:
        #
        #   memo which frame you found this node in, and memo that such
        #   a node's values is resolved through a "socialist" means
        #   (that is, that the name references a known node in the selection
        #   stack.)
        #
        #   if that node *is* in the pool (it "usually" is not), "tick off"
        #   the item from the pool (explained next).
        #
        # when you get to the end, any names that remain in the pool are
        # your #bespoke-set. associate with each of these names the fact that
        # the value of such nodes will be resolved through arguments only.

        @_did_index_big = true

        means_h = {}  # to build the evaluator (proc)

        _ = @formal_operation.to_defined_formal_parameter_stream
        stated_bx = _.flush_to_box_keyed_to_method :name_symbol

        pool = stated_bx.a_.dup
        pool_h = ::Hash[ pool.each_with_index.map { |*a| a } ]

        __init_expanse_stream stated_bx

        # -- (keep track of what frame every node appears in)

        frame_index_via_name_symbol = Callback_::Box.new
        my_stack = []

        frame_d = 0
        parent_index = nil

        st = ___to_below_frames_stream
        fr = st.gets
        begin

          idx = Here_::Frame_Index___.new fr, parent_index, self do |no|

            k = no.name_symbol
            frame_index_via_name_symbol.add k, frame_d
            d = pool_h[ k ]
            if d
              means_h[ k ] = :__touch_knownness_for_shared_parameter
              pool[ d ] = nil
            end
          end

          my_stack.push idx
          fr = st.gets
          fr or break
          parent_index = idx
          frame_d += 1
          redo
        end while nil

        @__indices = Indices___.new frame_index_via_name_symbol.h_, my_stack

        # --

        pool.compact!
        pool.each do |k|
          means_h[ k ] = :__lookup_knownness_for_bespoke_parameter
        end

        __init_bespoke_stream pool, stated_bx

        __init_evaluator means_h

        NIL_
      end

      def ___to_below_frames_stream

        ss = @formal_operation.selection_stack
        Callback_::Stream.via_range( 0 ... ss.length - 1 ) do |d|
          ss.fetch d
        end
      end

      # -- :"as parameter store"

      def accept_parameter_value x, par
        @_accept_to_real_store[ x, par ]
      end

      def evaluation_proc
        send @_EVP_via
      end

      def _EVP_when_heavy
        @_did_index_big || _index_big
        @__evaluate
      end

      def __EVP_when_light
        :_NEVER_CALLED_
      end

      def internal_store_substrate
        @_real_store.internal_store_substrate
      end

      # -- expanse stream (write, read)

      def __init_expanse_stream stated_bx

        @__build_expanse_stream_once = -> do  # or many times, even
          stated_bx.to_value_stream
        end ; nil
      end

      def __expanse_stream_once

        remove_instance_variable :@__once_ES

        # assume [#ac-028]:#API-point-A: bespoke parameters will NOT be
        # requested if the parameter value source is known to be empty.
        # (so avoid the heavy lift when we can)..

        if @parameter_value_source.is_known_to_be_empty
          __maybe_expanse_stream_lightly_because_PVS_is_known_to_be_empty
        else
          @_EVP_via = :_EVP_when_heavy
          ___expanse_stream_heavily
        end
      end

      def ___expanse_stream_heavily

        @_did_index_big ||= _index_big
        _ = remove_instance_variable :@__build_expanse_stream_once
        _.call
      end

      def __maybe_expanse_stream_lightly_because_PVS_is_known_to_be_empty

        # assume PVS is known to be empty. if also the formal operation has
        # no stated parameters, then we can procede without "heavy lift"

        st = @formal_operation.to_defined_formal_parameter_stream
        par = st.gets
        if par
          @_EVP_via = :_EVP_when_heavy
          p = -> { p = st ; par }  # recycle the stream you just started eew
          Callback_.stream { p[] }
        else
          @_EVP_via = :__EVP_when_light
          Callback_::Stream.the_empty_stream
        end
      end

      # -- bespoke stream (write, read):73

      def __init_bespoke_stream pool, stated_bx

        # the #bespoke-stream is whatever is left over in the pool at this
        # point (i.e those in the #stated-set that were not in the #scope-set.)

        _ = Callback_::Stream.via_nonsparse_array pool
        @__bespoke_stream = _.map_by do |k_|
          stated_bx.fetch k_
        end ; nil
      end

      def __bespoke_stream_once

        @_did_index_big || _index_big
        remove_instance_variable :@__bespoke_stream
      end

      # -- evaluation

      def __init_evaluator means_h

        @__evaluate = -> par, & no do

          if no
            self._MODERNIZE_ME_dont_pass_else_block
          end

          _ = means_h.fetch par.name_symbol
          _evl = send _, par
          _evl
        end
      end

      def __lookup_knownness_for_bespoke_parameter par

        # for these, just pass through. stay out of the way of the real store

        @_real_store.evaluation_of par
      end

      def __touch_knownness_for_shared_parameter par

        # shared parameters such as these have actual values that exist
        # either directly in the zerk tree already as ivars, or they exist
        # latently as the results of would-be operation calls.
        #
        # whether the formal is proc-implemented or non-proc-implemented,
        # we need to transfer these values to the actual (intermediate)
        # store that will ultimately be used to execute the operation.
        #
        # assuming [#ac-028]:#API-point-B, we are being called once for each
        # parameter of the "stated set" ("expanse" there) in order to apply
        # defaults and find missing required parameters.
        #
        # so we piggy-back onto this second fulfillment fulfillment of this
        # first need too EEK

        _sta = @__indices._touch_state par
        evl = _sta.cached_evaluation_

        if evl.is_known_known
          @_accept_to_real_store[ evl.value_x, par ]
        end

        evl
      end

      # -- handle events

      def __on_unavailable
        kn = remove_instance_variable :@_on_unavailable_kn
        if kn
          kn.value_x  # can be nil
        else
          @_oes_p
        end
      end

      def __on_emission * x_a, & x_p
        @___some_handler ||= ___determine_some_handler
        @___some_handler[ x_a, & x_p ]
        UNRELIABLE_
      end

      def ___determine_some_handler

        oes_p = @_pp[ :_not_sure_ ]
        if oes_p
          -> i_a, & ev_p do
            oes_p[ * i_a, & ev_p ]
          end
        else
          method :___handle_emission
        end
      end

      def ___handle_emission i_a, & ev_p  # #[#ca-066]

        if :error == i_a.first
          self._A
        else
          self._B
        end
      end

      # ==

      class Indices___

        def initialize h, a
          @_index_stack = a
          @_soc_h = h
        end

        def _touch_state par

          _ = @_soc_h.fetch par.name_symbol
          _frame_index = @_index_stack.fetch _
          _frame_index.touch_state__ par
        end
      end
    end
  end
end
# #history - distilled from the API invocation mechanism & formal operations.
