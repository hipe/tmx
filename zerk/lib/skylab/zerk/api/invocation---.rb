module Skylab::Zerk

  module API

    class Invocation___

      # implement exactly the two flowcharts of [#012].

      def initialize args, acs, & pp

        @_push_qualified_knownness_of_compound = -> qk do
          @selection_stack.push Here_::Compound_Frame___.new qk ; nil
        end

        _qk = Callback_::Qualified_Knownness[ acs, ROOT_ASSOCIATION___ ]
        @selection_stack = []
        @_push_qualified_knownness_of_compound[ _qk ]

        @ACS = acs
        @argument_stream = Callback_::Polymorphic_Stream.via_array args
        @_pp = pp
      end

      def execute  # result in a bound call or false-ish

        # implement the flowchart [#012]/figure-1

        begin

          if @argument_stream.no_unparsed_exists  # (a)
            x = __finish_as_value_inquiry_to_aforementioned_component
            break
          end

          parse = __maybe_parse_component_association  # (b)

          parse ||= __maybe_parse_formal_operation  # (c)

          parse ||= ___stop_parsing_because_no_such_association  # (d)

          if parse.keep_parsing
            redo
          end
          x = parse.parse_result
          break
        end while nil
        x
      end

      def ___stop_parsing_because_no_such_association

        _handler.call :error, :no_such_association do

          Here_::When_no_such_association___[ @selection_stack, @argument_stream ]
        end
        Stop_parsing_because_unable__[]
      end

      # -- parsing components (not operations)

      def __maybe_parse_component_association  # result parse-tuple or nil

        asc = @selection_stack.last.component_association_via_token(
          @argument_stream.current_token )

        if asc
          if asc.association_is_available  # (k)
            @argument_stream.advance_one
            if @argument_stream.no_unparsed_exists  # (m)

              _qk = @selection_stack.last.qualified_knownness_for_assoc__ asc
              _bc = _bound_call_for _qk
              Result__[ _bc ]
            else
              _ = asc.model_classifications.category_symbol
              send PARSE_AFTER_VIA_SHAPE___.fetch( _ ), asc
            end
          else
            ___when_association_is_not_available asc
          end
        else
          NOTHING_  # let the next guy try
        end
      end

      PARSE_AFTER_VIA_SHAPE___ = {
        compound: :__parse_after_compound_association,
        entitesque: :_EASYESQUE,  # #open [
        primitivesque: :__parse_after_primitiveque_association,
      }

      def ___when_association_is_not_available asc

        _handler.call :error, :association_is_not_available do
          Here_::When_association_is_not_available___[ @selection_stack, asc ]
        end
        Stop_parsing_because_unable__[]
      end

      def __parse_after_compound_association asc  # (q)

        _qk = ACS_::For_Interface::Touch[ asc, @selection_stack.last.value_x ]
        _qk or self._SANITY
        @_push_qualified_knownness_of_compound[ _qk ]

        # NOTE - in a slight break with the graph [#012]/figure-1, we are
        # about to loop back to one step farther back than the graph says to.
        # the effect will be the same, but we are about to make a check for
        # end of stream redundantly. we don't know a clean way around it.

        KEEP_PARSING__
      end

      def __parse_after_primitiveque_association asc  # (p)

        _kn = asc.component_model[ @argument_stream, & @_pp ]
        _receive_entitesque_or_primitivesque_known _kn, asc
      end

      def _receive_entitesque_or_primitivesque_known kn, asc
        if kn
          ___accept_new_component_value kn, asc
          KEEP_PARSING__
        else
          Result__[ kn ]
        end
      end

      def ___accept_new_component_value kn, asc

        p = @selection_stack.last.accept_new_component_value__ kn, asc

        _handler.call :info, :set_leaf_component do
          p[]
        end

        NIL_
      end

      # -- parsing operations (not components)

      def __maybe_parse_formal_operation

        Require_formal_operation___[]

        m = Formal_Op_.method_name_for_symbol @argument_stream.current_token

        if @selection_stack.last.value_x.respond_to? m
          ___parse_formal_operation m
        else
          NOTHING_
        end
      end

      Require_formal_operation___ = Lazy_.call do
        Formal_Op_ = ACS_::Operation::Formal_  # #violation
        NIL_
      end

      def ___parse_formal_operation m

        # we have our own weird selection stack and for now we don't want
        # to "pollute" it with the final name function that formal options
        # require at the top of their selection stacks..

        _sym = @argument_stream.current_token

        _nf = Callback_::Name.via_variegated_symbol _sym

        ss = @selection_stack.dup  # ours always has compound on top

        ss.push _nf

        fo = Formal_Op_.via_method_name_and_selection_stack m, ss

        if fo.operation_is_available

          ___parse_available_formal_operation fo
        else

          _handler.call :error, :operation_is_not_available do
            Here_::When_operation_is_not_available___[ fo ]
          end
          Stop_parsing_because_unable__[]
        end
      end

      def ___parse_available_formal_operation fo  # (e)

        @argument_stream.advance_one

        de = fo.deliverable_via_argument_stream @argument_stream, & @_pp

        if de  # (g)

          if @argument_stream.no_unparsed_exists  # (j)

            # (we discard the sel.stack of the deliv. use only the b.c)

            Result__[ de.bound_call ]

          else  # (h)
            ___stop_parsing_when_extra
          end

        else  # (f)
          Result__[ de ]
        end
      end

      def ___stop_parsing_when_extra

        x = @argument_stream.current_token
        _handler.call(
          :error, :expression, :arguments_continued_past_end_of_phrase
        ) do |y|
          y << "arguments continued passed end of phrase - #{
            }unexpected argument: #{ ick x }"
        end
        Stop_parsing_because_unable__[]
      end

      # -- finishers

      def __finish_as_value_inquiry_to_aforementioned_component

        _qk = @selection_stack.last.qualified_knownness_as_invocation_result__
        _bound_call_for _qk
      end

      def _bound_call_for x
        Callback_::Bound_Call.via_value x
      end

      # -- support

      def _handler
        @_pp[ @selection_stack.last.value_x ]
      end

      # --

      Stop_parsing_because_unable__ = Lazy_.call do
        Result__[ UNABLE_ ]
      end

      class Result__

        class << self
          alias_method :[], :new
          private :new
        end  # >>

        def initialize x
          @parse_result = x
        end

        def keep_parsing
          false
        end

        attr_reader :parse_result
      end

      class Keep_Parsing____
        def keep_parsing
          true
        end
      end

      KEEP_PARSING__ = Keep_Parsing____.new

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
