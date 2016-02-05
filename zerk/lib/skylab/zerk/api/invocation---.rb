module Skylab::Zerk

  module API

    class Invocation___

      # implement exactly the two flowcharts of [#012].

      def initialize args, acs, & pp

        @_push_compound_qk = -> qk do
          @_stack.push Here_::Compound_Frame___.new qk ; nil
        end

        _qk = Callback_::Qualified_Knownness[ acs, ROOT_ASSOCIATION___ ]

        @_memory = []
        @_stack = []
        @_push_compound_qk[ _qk ]

        @_stream = Callback_::Polymorphic_Stream.via_array args
        @_pp = pp
      end

      def execute  # result in a bound call or false-ish

        # implement the flowchart [#012]/figure-1

        begin

          if @_stream.no_unparsed_exists  # (a)
            x = __finish_as_value_inquiry_to_aforementioned_component
            break
          end

          parse = __maybe_parse_component_association  # (b)

          parse ||= __maybe_parse_formal_operation  # (c)

          parse ||= __maybe_pop_the_stack  # (d), (d2)

          parse ||= __stop_parsing_because_no_such_association  # (d3)

          if parse.keep_parsing
            redo
          end
          x = parse.parse_result
          break
        end while nil
        x
      end

      # -- parsing components (not operations)

      def __maybe_parse_component_association  # result parse-tuple or nil

        asc = @_stack.last.component_association_via_token__(
          @_stream.current_token )

        if asc
          ___maybe_parse_this_component_association asc
        else
          NOTHING_  # let the next guy try
        end
      end

      def ___maybe_parse_this_component_association asc  # (k)

        # (implementation of availiability is not reflected in [#012])

        @_memory.clear
        p = asc.unavailability
        if p
          __when_association_is_not_available p, asc
        else
          ___parse_this_component_association asc
        end
      end

      def ___parse_this_component_association asc
        @_stream.advance_one
        if @_stream.no_unparsed_exists  # (m)

          _qk = @_stack.last.qualified_knownness_of_association__ asc
          _bc = _bound_call_for _qk
          Result__[ _bc ]
        else
          _ = asc.model_classifications.category_symbol
          send PARSE_AFTER_VIA_SHAPE___.fetch( _ ), asc
        end
      end

      PARSE_AFTER_VIA_SHAPE___ = {
        compound: :__parse_after_compound_association,
        entitesque: :_parse_after_non_compound_association,
        primitivesque: :_parse_after_non_compound_association,
      }

      def __parse_after_compound_association asc  # (q)

        o = ACS_::Interpretation::Touch.new
        o.component_association = asc
        o.reader_writer = @_stack.last.reader_writer

        qk = o.execute
        qk or self._SANITY
        @_push_compound_qk[ qk ]

        # NOTE - in a slight break with the graph [#012]/figure-1, we are
        # about to loop back to one step farther back than the graph says to.
        # the effect will be the same, but we end up making a redundant check
        # for end of stream. we don't know a clean way around it.

        KEEP_PARSING__
      end

      def _parse_after_non_compound_association asc  # (p)

        qk = ACS_::Interpretation::Build_value[
          @_stream,
          asc,
          @_stack.last.ACS,
          & @_pp ]

        if qk

          p = @_stack.last.accept_component_change__ qk

          _handler.call :info, :set_leaf_component do
            p[]
          end

          KEEP_PARSING__
        else
          Result__[ qk ]
        end
      end

      # -- parsing operations (not components)

      def __maybe_parse_formal_operation

        _rw = @_stack.last.reader_writer

        fo = _rw.read_formal_operation @_stream.current_token

        if fo
          ___when_formal_operation fo
        else
          NOTHING_
        end
      end

      def ___when_formal_operation fo_p

        # we maintain our own internal selection stack and for now we don't
        # want to "pollute" it with the final name-function-as-frame that
        # formal options require at the top of their selection stacks..

        @_memory.clear

        _sym = @_stream.current_token

        _nf = Callback_::Name.via_variegated_symbol _sym

        ss = @_stack.dup  # ours always has compound on top

        ss.push _nf

        fo = fo_p[ ss ]

        p = fo.unavailability
        if p
          ___when_operation_not_available p, fo
        else
          __parse_available_formal_operation fo
        end
      end

      def ___when_operation_not_available p, fo

        a = p.call
        if a
          _express_this a
        else
          _handler.call :error, :operation_is_not_available do
            Here_::When_operation_is_not_available___[ fo ]
          end
        end

        Stop_parsing_because_unable__[]
      end

      def __when_association_is_not_available p, asc

        a = p.call
        if a
          _express_this a
        else
          _handler.call :error, :association_is_not_available do
            Here_::When_association_is_not_available___[ @_stack, asc ]
          end
        end

        Stop_parsing_because_unable__[]
      end

      def _express_this a
        ( * sym_a, ev_p ) = a
        _handler.call( * sym_a, & ev_p )
        NIL_
      end

      def __parse_available_formal_operation fo  # (e)

        @_stream.advance_one

        de = fo.deliverable_via_argument_stream @_stream, & @_pp

        if de  # (g)

          if @_stream.no_unparsed_exists  # (j)

            # (we discard the sel.stack of the deliv. use only the b.c)

            Result__[ de.bound_call ]

          else  # (h)
            ___stop_parsing_when_extra
          end

        else  # (f)
          Result__[ de ]
        end
      end

      def __maybe_pop_the_stack

        if 1 < @_stack.length
          _bye_bye = @_stack.pop
          @_memory.push _bye_bye
          KEEP_PARSING__
        end
      end

      def __stop_parsing_because_no_such_association

        while @_memory.length.nonzero?
          @_stack.push @_memory.pop
        end

        _handler.call :error, :no_such_association do

          Here_::When_no_such_association___[ @_stack, @_stream ]
        end

        Stop_parsing_because_unable__[]
      end

      def ___stop_parsing_when_extra

        x = @_stream.current_token
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

        _qk = @_stack.last.qualified_knownness_as_invocation_result__
        _bound_call_for _qk
      end

      def _bound_call_for x
        Callback_::Bound_Call.via_value x
      end

      # -- support

      def _handler
        @_pp[ @_stack.last.ACS ]
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
