module Skylab::Zerk

  module Invocation_

    class Procure_bound_call

      # the entirety of [#027] documents this excessively, as referenced.

      class << self

        def begin_ pvs, fo, & pp
          1 == pp.arity or raise ::ArgumentError
          _begin_empty.__init_initial pvs, fo, & pp
        end

        alias_method :_begin_empty, :new
        undef_method :new
      end  # >>

      # -- initialization

      def __init_for_recursion fo, ts, si, & oes_p

        @formal_operation = fo
        @parameter_value_source = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source
        @_oes_p = oes_p
        @_scope_index = si
        @_trouble_stack = ts

        @_did_emit = false

        @_on_unavailable_kn = Callback_::Known_Known[ -> * i_a, & ev_p do

          @_did_emit = true

          # (be *the* contributor of [#fi-036]:"Storypoint-1":)
          _reasoning = ( @_reasoning ||= Reasoning___.new( fo ) )
          _reasoning.__add i_a, & ev_p

          UNRELIABLE_
        end ]

        _common_init
      end

      def __init_initial pvs, fo, & pp

        @formal_operation = fo
        @_on_unavailable_kn = nil
        @parameter_value_source = pvs
        @_pp = pp
        @_trouble_stack = nil
        _common_init
      end

      def _common_init

        @_did_index_big = false
        @__once_ES = nil
        self
      end

      def on_unavailable_= x
        @_on_unavailable_kn = Callback_::Known_Known[ x ] ; x
      end

      # --

      def begin_recursion__ fo

        ts = @_trouble_stack
        if ts
          self._A
        else
          ts = [ self ]
        end

        _otr = self.class._begin_empty
        _otr.__init_for_recursion fo, ts, @_scope_index, & @_oes_p
      end

      def evaluate_recursion__  # result in an "evaluation" struct

        bc = execute
        if bc

          # this is at the behest of etc meh. just do it now:

          _oes_p = @_on_unavailable_kn.value_x

          ok_x = bc.receiver.send bc.method_name, * bc.args, & _oes_p
          if ok_x

            if @_did_emit
              self._WEEE  # maybe emit the events back into the bc block # #todo
            end

            Callback_::Known_Known[ ok_x ]
          else

            _ = remove_instance_variable :@_reasoning

            # (when the above fails, design something. hopefully all failure
            #  of dependee operations will have client-provided emission.)

            Callback_::Known_Unknown.via_reasoning _
          end
        else
          _ = remove_instance_variable :@_reasoning
          Callback_::Known_Unknown.via_reasoning _
        end
      end

      def begin_customizable_session__
        bc = execute
        if bc
          # take a leap of faith and discard the args, block and method name
          bc.receiver
        else
          self._COVER_ME_when_did_not_procure_bound_call_look_around
          # (make sure you emit everything.)
          # (you should be fine to result in false from here..)
        end
      end

      def execute

        ___prepare

        o = @formal_operation.begin_preparation( & @_oes_p )

        o.bespoke_stream_once = method :__bespoke_stream_once

        o.expanse_stream_once = method :__expanse_stream_once

        o.on_unavailable = __on_unavailable

        o.parameter_store = self  # so "as parameter store" below

        o.parameter_value_source = @parameter_value_source

        o.to_bound_call
      end

      def ___prepare

        @_oes_p ||= method :__on_emission  # already set #IFF-recursion (see #"c1")
        @_real_store = @formal_operation.begin_parameter_store( & @_oes_p )
        @_accept_to_real_store = @_real_store.method :accept_parameter_value
        NIL_
      end

      # -- execution support

      def _index_big  # all note continuations are under #"c2"

        # avoid this #"heavy lift" whenver possible..

        @_did_index_big = true

        means_h = {}  # to build the evaluator proc, a #"means" for every..

        stated_bx = __build_and_etc_stated_box
        pool = stated_bx.a_.dup  # a #"diminishing pool"
        pool_h = ::Hash[ pool.each_with_index.map { |*a| a } ]

        # iterate over every node name in the scope #"as a stream" because..

        st = __scope_node_name_symbol_stream  # we #"could optimize"..
        begin
          k = st.gets
          k or break
          d = pool_h[ k ]
          if d
            pool[ d ] = nil
            means_h[ k ] = :__touch_knownness_for_shared_parameter
          end
          redo
        end while nil

        pool.compact!
        pool.each do |k_|
          means_h[ k_ ] = :__lookup_knownness_for_bespoke_parameter
        end

        __init_bespoke_stream pool, stated_bx

        __init_evaluator means_h

        NIL_
      end

      def __build_and_etc_stated_box

        _ = @formal_operation.to_defined_formal_parameter_stream
        stated_bx = _.flush_to_box_keyed_to_method :name_symbol

        @__build_expanse_stream_once = -> do  # or many times, even
          stated_bx.to_value_stream
        end

        stated_bx
      end

      def __scope_node_name_symbol_stream
        if @_trouble_stack
          @_scope_index.__to_name_symbol_stream
        else
          ___scope_node_name_symbol_stream_from_ground_floor
        end
      end

      def ___scope_node_name_symbol_stream_from_ground_floor

        # intro & continuations at #"c3"

        current_frame_node_stream = nil
        current_frame_index = nil
        my_stack = []
        frame_d = 0
        frame_index_via_name_symbol = Callback_::Box.new
        parent_index = nil

        st = ___to_below_frames_stream
        fr = st.gets

        on_frame = -> do
          current_frame_index = Here_::Frame_Index___.new fr, parent_index, self
          current_frame_node_stream = current_frame_index.to_node_ticket_stream__
        end

        on_frame[]

        p = -> do

          begin
            nt = current_frame_node_stream.gets
            if nt
              x = nt.name_symbol
              frame_index_via_name_symbol.add x, frame_d
              break
            end
            my_stack.push current_frame_index
            fr = st.gets
            if fr
              parent_index = current_frame_index
              frame_d += 1
              on_frame[]
              redo
            end

            @_scope_index = Scope_Index___.new frame_index_via_name_symbol, my_stack

            p = EMPTY_P_
            break
          end while nil
          x
        end

        Callback_.stream do
          p[]
        end
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

      def __touch_knownness_for_shared_parameter par  # :"c5"

        # --

        if @_real_store.is_classesque
          m = :"finish__#{ par.name_symbol }__by"
          yes = @_real_store.internal_store_substrate.respond_to? m
        end

        if yes
          _ = __custom_operation_dependency m, par
          _
        else
          __touch_knownness_for_shared_parameter_normally par
        end
      end

      def __touch_knownness_for_shared_parameter_normally par

        _sta = @_scope_index._touch_state par
        evl = _sta.cached_evaluation_

        if evl.is_known_known
          @_accept_to_real_store[ evl.value_x, par ]
        end

        evl
      end

      def __custom_operation_dependency m, par

        sub_sess = @_scope_index.__begun_session_for par

        if sub_sess

          sess = @_real_store.internal_store_substrate

          ok_x = sess.send m, sub_sess

          @_real_store.accept_parameter_value ok_x, par  # for now, always..

        else
          ok_x = sub_sess
        end

        Callback_::Known_Known[ ok_x ]
      end

      # -- handle events

      def __on_unavailable
        kn = @_on_unavailable_kn  # used 1x more later..
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

      class Reasoning___  # a member of our [#030] unified language

        def initialize fo
          @compound_formal_attribute = fo  # experimental name
          @emissions = []
        end

        def __add i_a, & ev_p
          @emissions.push Emission___.new( i_a, ev_p ) ; nil
        end

        attr_reader(
          :compound_formal_attribute,
          :emissions,
        )
      end

      class Emission___  # a member of our [#030] unified language

        def initialize i_a, x_p
          @channel = i_a
          @mixed_event_proc = x_p
        end

        attr_reader(
          :channel,
          :mixed_event_proc,
        )
      end

      class Scope_Index___

        def initialize bx, a
          @_index_stack = a
          @_lookup_box = bx
        end

        def __begun_session_for par

          _ = _frame_index_for par
          _.begun_session_for__ par
        end

        def _touch_state par

          _ = _frame_index_for par
          _.touch_state__ par
        end

        def _frame_index_for par

          @_index_stack.fetch @_lookup_box.fetch par.name_symbol
        end

        def __to_name_symbol_stream
          @_lookup_box.to_name_stream
        end
      end
    end
  end
end
# #history - distilled from the API invocation mechanism & formal operations.
