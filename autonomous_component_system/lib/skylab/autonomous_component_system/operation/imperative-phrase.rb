module Skylab::Autonomous_Component_System

  module Operation

    class Imperative_Phrase  # 1x

      # required reading: algorithm in :[#014]

      class << self

        def call_via_these__ as, rw, & pp
          new( as, rw, & pp ).execute
        end

        private :new
      end  # >>

      def initialize as, rw, & pp
        @argument_stream = as
        @_pp = pp
        @_stack_base = [ rw ]
      end

      def execute

        # the main thing we "do" as a session-like is produce a proc that
        # `gets`'s each next phrase-parsing structure for each next phrase

        -> do
          if @argument_stream.unparsed_exists
            dup  # nothing to init. all the work is in the next method..
          end
        end
      end

      def to_unit_of_work  # assume unparsed exists

        # [modifiers] verb_token [operand_sub_name [..]] [args]
        #
        # e.g "via integer if not_set set dotily identifier 10"

        @_stack = @_stack_base.dup

        __parse_zero_or_more_modifiers
        __parse_verb
        __parse_zero_or_more_operands
        ok = __finish_selection_stack
        ok &&= __resolve_formalesque
        ok and @_normal_representation.deliverable_for_imperative_phrase_ self
      end

      def call_handler_  # for above..

        # ..per [#004]#exceptions we raise them when etc. but the custom
        # implementation of operation is entitled to a plain old handler
        # to emit arbitrary emissions.

        @_pp[ NOTHING_ ]  # we *could* pass the receiver..
      end

      def build_parameter_value_source_
        Home_::Parameter::ValueSource_for_ArgumentStream.new @argument_stream
      end

      def __parse_zero_or_more_modifiers  # we peek before loading the node

        if MODIFIER_KEYWORDS___[ @argument_stream.current_token ]
          o = Here_::Modifiers_::Parse.call_via_argument_stream__ @argument_stream
        end

        @modz_ = o
        NIL_
      end

      MODIFIER_KEYWORDS___ = {
        # (avoid needlessly loading the node by manually duplicating keywords)
        assuming: true,
        if: true,
        using: true,
        via: true,
      }

      def __parse_verb  # you can't validate it yet

        @_imperative_verb_symbol = @argument_stream.gets_one
        NIL_
      end

      def __parse_zero_or_more_operands  # 1-(N+1) for 0-N operand subnames

        # at any point if one of the component associations you traverse
        # has the transitive capability (to be the deliveree), go that route.

        o = Here_::Node_Parse.begin_via_these__(
          @_stack,
          @argument_stream,
        )

        sym = @_imperative_verb_symbol

        asc_with_transitive_capability = nil
        transitive_found = false

        o.build_frame_by( & Build_frame_by_qk__ )

        o.stop_if = -> asc do
          bx = asc.transitive_capabilities_box
          if bx and bx.has_name sym
            @argument_stream.advance_one
            asc_with_transitive_capability = asc
            transitive_found = true
            true
          end
        end

        o.execute

        @_transitive_found = transitive_found
        if transitive_found
          @_assoc_with_transitive_capability = asc_with_transitive_capability
        end

        NIL_
      end

      def __finish_selection_stack

        if @_transitive_found
          ___finish_selection_stack_for_transitive
        else

          if @modz_
            self._COVER_ME_you_cant_use_modifiers_with_formal_operations
          end

          __finish_selection_stack_for_formal
        end
      end

      # ~ for transitive

      def ___finish_selection_stack_for_transitive

        _asc = remove_instance_variable :@_assoc_with_transitive_capability

        qk = _build_this_under_top_of_selection_stack _asc

        if qk
          @_deliveree_qk = qk
          _push_operation_name_on_to_selection_stack
          ACHIEVED_
        else
          qk
        end
      end

      # ~ for formal

      def __finish_selection_stack_for_formal

        # the top of the selection stack is the lastmost compound node
        # that could be parsed off of the argument stream. (perhaps none
        # could, then it is the argument ACS.)

        # if this compound node itself defines the formal operation..

        _rw = @_stack.last.reader_writer

        fo_p = _rw.read_formal_operation @_imperative_verb_symbol

        if fo_p
          @_fo_p = fo_p
          _push_operation_name_on_to_selection_stack
          ACHIEVED_
        else
          @_fo_p = nil  # eew
          ___finish_selection_stack_for_formal_with_one_more_descent
        end
      end

      def ___finish_selection_stack_for_formal_with_one_more_descent

        # since the verb was not defined by the last-matched compound, we
        # assume the head of the argument stream represents a non-compound
        # node (primitivesque or entitesque) we need to build in order to
        # find the recipient for the verb..

        _rw = @_stack.last.reader_writer
        _asc = _rw.read_association @argument_stream.current_token
        _asc or self._COVER_ME

        @argument_stream.advance_one

        qk = _build_this_under_top_of_selection_stack _asc
        if qk

          # because this is the recipient (not the deliveree) of the
          # operation, it goes on the stack

          @_stack.push Build_frame_by_qk__[ qk ]

          # the verb we parsed earlier is intended to be sent to above.
          _push_operation_name_on_to_selection_stack

          ACHIEVED_
        else
          qk
        end
      end

      # ~ support

      def _build_this_under_top_of_selection_stack asc

        # NOTE result is "floating". it is an #open [#016] question as to
        # whether this would steamroll existing components in a graph..
        # it seems that it would.

        if @modz_
          via = @modz_.via
        end

        if via
          ___build_via_via via, asc
        else
          __build_normally asc
        end
      end

      def ___build_via_via via, asc  # :[#002]:Tenet7.
        _x = @argument_stream.gets_one
        comp_x = asc.component_model.send :"new_via__#{ via }__", _x, & @_pp
        if comp_x
          Callback_::Qualified_Knownness[ comp_x, asc ]
        else
          comp_x
        end
      end

      def __build_normally asc

        _ACS = @_stack.last.ACS

        ACS_::Interpretation::Build_value.call(
          @argument_stream, asc, _ACS, & @_pp )
      end

      def _push_operation_name_on_to_selection_stack
        _sym = remove_instance_variable :@_imperative_verb_symbol
        @_stack.push Callback_::Name.via_variegated_symbol _sym
        NIL_
      end

      # --

      def __resolve_formalesque

        if @_transitive_found
          ___resolve_formalesque_for_transitive
        else
          __resolve_formalesque_for_formal
        end
      end

      def ___resolve_formalesque_for_transitive

        _qk = remove_instance_variable :@_deliveree_qk
        @_normal_representation = Here_::NormalRepresentation_for_Method___.new _qk
        ACHIEVED_
      end

      def __resolve_formalesque_for_formal

        # any remainder of the arg stream that we can parse represents
        # arguments to the would-be formal operation ..

        fo_p = remove_instance_variable :@_fo_p

        if fo_p

          fo = fo_p[ @_stack ]

        else

          # as covered, this is a hail mary ..
          _sym = @_stack.last.as_variegated_symbol
          _eek = @_stack.fetch( -2 ).reader_writer.read_formal_operation _sym
          fo = _eek[ @_stack ]
        end

        @_normal_representation = fo.normal_representation_

        ACHIEVED_
      end

      # -- for sub-clients

      def selection_stack_
        @_stack
      end

      attr_reader(
        :modz_,
      )

      # --

      Build_frame_by_qk__ = -> qk do
        My_Frame___.new qk
      end

      class My_Frame___

        def initialize qk
          @association = qk.association
          @ACS = qk.value_x
        end

        def reader_writer
          @___rw ||= Home_::ReaderWriter.for_componentesque @ACS
        end

        def name
          @association.name
        end

        # -- (rather than implement `to_qualified_knownness` but ..)

        def value_x
          @ACS
        end

        def is_known_known
          true
        end

        # --

        attr_reader(
          :ACS,
          :association,
        )
      end
    end
  end
end
