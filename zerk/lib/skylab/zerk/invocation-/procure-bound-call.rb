module Skylab::Zerk

  module Invocation_

    class Procure_bound_call

      # the entirety of [#027] documents this excessively, as referenced.

      class << self

        def begin_ pvs, fo, & pp
          _begin_empty.__init_initial pvs, fo, & pp
        end

        alias_method :_begin_empty, :new
        undef_method :new
      end  # >>

      # -- initialization

      def begin_recursion__ fo

        ts = @_trouble_stack
        if ts
          ts = [ * ts, self ]
        else
          ts = [ self ]
        end

        _otr = self.class._begin_empty
        _otr.__init_for_recursion fo, ts, @_operation_index, & @_oes_p
      end

      def __init_for_recursion fo, ts, bi, & oes_p

        @did_emit_ = false
        @formal_operation = fo
        @_oes_p = oes_p
        @parameter_value_source = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source
        @_trouble_stack = ts

        @on_unavailable_kn_ = Callback_::Known_Known[ -> * i_a, & ev_p do

          @did_emit_ = true

          # (be *the* contributor of [#fi-036]:"Storypoint-1":)
          _reasoning = ( @_reasoning ||= Reasoning___.new( fo ) )
          _reasoning.__add i_a, & ev_p

          UNRELIABLE_
        end ]

        @_has_operation_index = true
        @_operation_index = bi.dup_for_recursion_ fo

        _common_init
      end

      def release_reasoning_
        remove_instance_variable :@_reasoning
      end

      attr_reader(
        :did_emit_,
      )

      def __init_initial pvs, fo, & pp

        @formal_operation = fo
        @_has_operation_index = false
        @on_unavailable_kn_ = nil
        @parameter_value_source = pvs
        @_pp = pp
        @_trouble_stack = nil
        _common_init
      end

      def _common_init
        @__once_ES = nil
        self
      end

      def operation_index= oi
        @_has_operation_index = true
        @_operation_index = oi
      end

      def on_unavailable_= x
        @on_unavailable_kn_ = Callback_::Known_Known[ x ] ; x
      end

      # --

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

        @_oes_p ||= method :__on_emission  # already set #IFF-recursion (see #"c1")
        @real_store_ = @formal_operation.begin_parameter_store( & @_oes_p )
        @_accept_to_real_store = @real_store_.method :accept_parameter_value

        ___init_stated_box

        o = @formal_operation.begin_preparation( & @_oes_p )

        o.PVS_parameter_stream_once = method :__PVS_parameter_stream_once

        o.expanse_stream_once = method :__expanse_stream_once

        o.on_unavailable = __on_unavailable

        o.parameter_store = self  # so "as parameter store" below

        o.parameter_value_source = @parameter_value_source

        o.to_bound_call
      end

      def ___init_stated_box

        @_stated_box =
          @formal_operation.to_defined_formal_parameter_stream.
            flush_to_box_keyed_to_method :name_symbol
        NIL_
      end

      # -- WEEPOLY DOPOLY DOOPOLY BOPOLY

      # from [#027] recall the difference between stateds and bespokes.
      # to determine which of the stateds are bespokes (and which are
      # appropriateds) we have to make the operation index. but this index
      # is a heavy lift that we want to avoid if we can.
      #
      # we introduce this twist that allows us to avoid this heavy lift for
      # some cases, leading to some snappier invocations and more robust
      # regressions. the cost is in mental overhead. the twist is this: the
      # bespokes are requested IFF the parameter value source is not known
      # to be empty. that is, if the PVS is known to be empty the parser
      # will not request the bespokes. #[#ac-028]:#API-point-A.
      #
      # note however that if we have any stateds, we have to do the heavy
      # lift to determine how to evaluate them..

      def __expanse_stream_once  # first,

        # what is the expanse of all parameters you use to
        # effect defaulting and checking for missing requireds?

        if @_stated_box.length.zero?
          @_evaluation_proc = :__evaluation_proc_which_is_never_called
          Callback_::Stream.the_empty_stream
        else
          @_has_operation_index || _init_operation_index
          @_evaluation_proc = :__real_evaluation_proc
          @_stated_box.to_value_stream
        end
      end

      def evaluation_proc  # then,
        send @_evaluation_proc
      end

      def __evaluation_proc_which_is_never_called
        :_NEVER_CALLED_ # must be true-ish
      end

      def __real_evaluation_proc  # then, with whatever was set above, we do
        # THE MAIN THING which is that [ze] suppports (encourages even)
        # "appropriateds" but [ac] doesn't have any built-in sense for what
        # those even are. so here is where we transfer those values from the
        # ACS tree to the parameter store for the operation implementation.

        p = @_operation_index.evaluation_proc_for_ self

        -> par do
          kn = p[ par ]
          if kn.is_known_known && @_operation_index.is_appropriated_( par.name_symbol )
            @real_store_.accept_parameter_value kn.value_x, par
          end
          kn
        end
      end

      def __PVS_parameter_stream_once  # so you know you've got non-empty PVS

        @_has_operation_index || _init_operation_index
        @_operation_index.to_PVS_parameter_stream_
      end

      # -- as parameter store ( & nearby )

      def accept_parameter_value x, par
        @_accept_to_real_store[ x, par ]
      end

      def evaluate_bespoke_parameter__ par
        # for these, just pass through. stay out of the way of the real store
        @real_store_.evaluation_of par
      end

      def internal_store_substrate
        @real_store_.internal_store_substrate
      end

      # -- this

      def _init_operation_index
        @_has_operation_index = true
        @_operation_index = Here_::Operation_Index.for_top_(
          @_stated_box, @formal_operation )
        NIL_
      end

      # -- handle events

      def __on_unavailable
        kn = @on_unavailable_kn_  # used 1x more later..
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

      # -- all for dependencies:

      attr_reader(
        :formal_operation,  # 2x by op index
        :on_unavailable_kn_,  # 1x by b.s
        :real_store_,  # 2x. by b.s
      )

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
    end
  end
end
# #history - distilled from the API invocation mechanism & formal operations.
