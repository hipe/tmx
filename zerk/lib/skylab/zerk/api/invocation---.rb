module Skylab::Zerk

  module API

    class Invocation___

      # implement exactly the two flowcharts of [#012]

      def initialize args, acs, & pp

        # • re-use the same logic from the other lib that parses compound
        #   nodes for *its* implementation of operations. it will be as a
        #   "sidecar" to the subject performer.
        #
        # • but we exercise options of it so that our stack is made up of
        #   custom frames.

        @ACS = acs
        @argument_stream = Callback_::Polymorphic_Stream.via_array args

        o = ACS_::Operation::Node_Parse.begin_for self, & pp
        remove_instance_variable :@ACS

        stack = []

        push = -> qk do
          stack.push Here_::Compound_Frame___.new qk
          NIL_
        end

        _qk = Callback_::Qualified_Knownness[ acs, ROOT_ASSOCIATION___ ]
        push[ _qk ]

        o.push = push
        o.stack = stack

        o.non_compound = -> asc do
          @_non_compound = asc ; false
        end

        @_node_parse = o
        @_pp = pp
        @selection_stack = stack
      end

      def execute  # result in a bound call or false-ish

        begin
          @_non_compound = nil
          @_node_parse.execute  # parses 0 or more compounds.

          if @argument_stream.no_unparsed_exists  # then all were compound.

            x = __result_in_top_compound_qk
            break
          end

          @_keep_parsing = false

          if @_non_compound  # if the node parse stopped because non-compound

            send @_non_compound.model_classifications.category_symbol  # EEK
            if @_keep_parsing
              redo
            end
            x = remove_instance_variable :@_parse_result
            break
          end

          # if we are here then the parse stopped at a token that was not
          # a component association. try to parse it as an operation or fail.

          formal_operation

          x = remove_instance_variable :@_parse_result
          break
        end while nil
        x
      end

      # -- parse WHEN (careful!) READ THIS:
      #
      # for each of these, assume @_non_compound.
      # use @_keep_parsing and if false, @_parse_result.

      def primitivesque

        asc = _next_autonomously_parsable_association
        if asc
          ___autonomously_parse_via_primitivesque asc
        end
        NIL_
      end

      def entitesque

        asc = _next_autonomously_parsable_association
        if asc
          ___autonomously_parse_via_entitesque asc
        end
        NIL_
      end

      def _next_autonomously_parsable_association

        asc = remove_instance_variable :@_non_compound

        if asc.association_is_available

          @argument_stream.advance_one  # only now can we accept the token

          if @argument_stream.no_unparsed_exists
            _finish_parse_by_resulting_in_a_qk_for asc
            NIL_
          else
            asc
          end
        else
          @_parse_result = UNABLE_
          __when_association_is_not_available asc
          NIL_
        end
      end

      def ___autonomously_parse_via_primitivesque asc

        _kn = asc.component_model[ @argument_stream, & @_pp ]
        _after_autonomous_parse _kn, asc
        NIL_
      end

      def ___autonomously_parse_via_entitesque asc

        self._COVER_ME_worked_once_then_we_changed_the_fixture

        qk = @selection_stack.last.read asc
        if qk.is_known_known
          self._DECIDE_BEHAVIOR_HERE_do_we_steamroll_the_old_entity_entirely?
        end
        _kn = asc.component_model.interpret_component @argument_stream, & @_pp
        _after_autonomous_parse _kn, asc
        NIL_
      end

      def _after_autonomous_parse kn, asc
        if kn
          ___accept_new_component_value kn, asc

          if @argument_stream.no_unparsed_exists

            _qk = Callback_::Qualified_Knownness[ kn.value_x, asc ]
            _finish_parse_by_resulting_in _qk
          else
            @_keep_parsing = true
          end
        else
          @_keep_parsing = false
          @_parse_result = kn  # OK to use false-ish instead of b.c
        end
        NIL_
      end

      def ___accept_new_component_value kn, asc

        p = ACS_::Interpretation::Accept_component_change[
          kn.value_x,
          asc,
          @selection_stack.last.value_x,
        ]

        _handler.call :info, :set_leaf_component do
          p[]
        end

        NIL_
      end

      def formal_operation  # set @_parse_result

        # for now, because the sel. stack is intrinsic to a formal op
        # and we want to control how the sel. stack is built, parsing
        # a formal is not exactly straightforward:

        @_Formal = ACS_::Operation::Formal_  # #violation
        @ACS = @selection_stack.last.value_x  # end of the line, ok now

        m = @_Formal.method_name_for_symbol @argument_stream.current_token

        _x = if @ACS.respond_to? m
          ___yes_formal_operation m
        else
          __when_no_such_association
        end
        @_parse_result = _x
        NIL_
      end

      def ___yes_formal_operation m  # result in parse result

        # because (thankfully) we only effect one operation per invocation..

        @_keep_parsing = false

        _op_name_symbol = @argument_stream.gets_one

        _nf = Callback_::Name.via_variegated_symbol _op_name_symbol

        otr = @selection_stack.dup  # ours always has compound on top
        otr.push _nf
        fo = @_Formal.via_method_name_and_selection_stack m, otr

        if fo.operation_is_available
          de = fo.deliverable_via_selecting_session self, & @_pp
        else
          de = __when_operation_not_available fo
        end

        if de
          if @argument_stream.no_unparsed_exists
            de
          else
            __when_extra
          end
        else
          de
        end
      end

      def _finish_parse_by_resulting_in_a_qk_for asc

        _qk = @selection_stack.last.read asc
        _finish_parse_by_resulting_in _qk
        NIL_
      end

      def _finish_parse_by_resulting_in qk
        @_keep_parsing = false
        @_parse_result = _result_in_value qk
        NIL_
      end

      # -- resulting

      def __when_no_such_association

        _handler.call :error, :no_such_association do
          Here_::When_no_such_association___[ self ]
        end
        UNABLE_
      end

      def __when_association_is_not_available asc

        _handler.call :error, :association_is_not_available do
          Here_::When_association_is_not_available___[ @selection_stack, asc ]
        end
        UNABLE_
      end

      def __when_operation_not_available fo

        _handler.call :error, :operation_is_not_available do
          Here_::When_operation_is_not_available___[ fo ]
        end
        UNABLE_
      end

      def __when_extra

        x = @argument_stream.current_token
        _handler.call(
          :error, :expression, :arguments_continued_passed_end_of_phrase
        ) do |y|
          y << "arguments continued passed end of phrase - #{
            }unexpected argument: #{ ick x }"
        end
        UNABLE_
      end

      def _handler

        @_pp[ @selection_stack.last.value_x ]
      end

      def __result_in_top_compound_qk

        _result_in_value @selection_stack.last.qualified_knownness
      end

      def _result_in_value x
        Callback_::Bound_Call.via_value x
      end

      # -- for sub-clients [ac]

      attr_reader(
        :ACS,
        :argument_stream,
        :selection_stack,
      )

      class Root_Association____

        # root nodes of the ACS never have an association (because they have
        # no custodian), but it *might* be algorithmically convenient for us
        # to be able to wrap the top ACS in a qualified knownness like we do
        # with the others so we mock out an ersatz assoc here experimentally

        def model_classifications
          ACS_::Component_Association::LOOKS_LIKE_COMPOUND
        end
      end

      ROOT_ASSOCIATION___ = Root_Association____.new
    end
  end
end
