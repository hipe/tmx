module Skylab::Zerk

  module API

    class Invocation___

      # implement exactly the two flowcharts of [#012].

      def initialize args, acs, & pp

        @_push_compound_qk = -> qk do
          @_stack.push Here_::CompoundFrame___.new qk ; nil
        end

        _qk = Common_::QualifiedKnownKnown[ acs, ROOT_ASSOCIATION___ ]

        @_memory = []
        @_stack = []
        @_push_compound_qk[ _qk ]

        @_scanner = Common_::Scanner.via_array args
        @_pp = pp
      end

      def execute  # result in a bound call or false-ish

        # implement the flowchart [#012]/figure-1

        begin

          if @_scanner.no_unparsed_exists  # (a)
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
          @_scanner.head_as_is )

        if asc
          ___maybe_parse_this_component_association asc
        else
          NOTHING_  # let the next guy try
        end
      end

      def ___maybe_parse_this_component_association asc  # (k)

        # (implementation of availiability is not reflected in [#012])

        @_memory.clear
        p = asc.unavailability_proc
        if p
          unava_p = p[ asc ]
        end
        if unava_p
          ACS_::Events::ComponentNotAvailable::Act[ unava_p, asc, @_stack ]  # raises
        else
          ___parse_this_component_association asc
        end
      end

      def ___parse_this_component_association asc
        @_scanner.advance_one
        if @_scanner.no_unparsed_exists  # (m)

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

        o = Arc_::Magnetics::TouchComponent_via_Association_and_FeatureBranch.new
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

        qk = Arc_::Magnetics::QualifiedComponent_via_Value_and_Association.call(
          @_scanner,
          asc,
          @_stack.last.ACS,
          & @_pp )

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

        fo = _rw.read_formal_operation @_scanner.head_as_is

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

        ss = @_stack.dup  # ours always has compound on top

        ss.push Common_::Name.via_variegated_symbol @_scanner.gets_one  # (e)

        # as it does in the chart, here the (g)/(f) fork must happen
        # *before* the (j)/(h) fork because of "bespoke"s.

        _pvs = Arc_::Magnetics::ParameterValueSource_via_ArgumentScanner.new @_scanner


        o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, fo_p[ ss ], & @_pp

        o.on_unavailable_ = NOTHING_  # throw exeptions

        bc = o.execute

        if bc  # (g)
          if @_scanner.no_unparsed_exists  # (j)
            Result__[ bc ]
          else
            __stop_parsing_when_extra  # (h)
          end
        else
          Stop_parsing_because_unable__[]  # (f)
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

          Here_::When_no_such_association___[ @_stack, @_scanner ]
        end

        Stop_parsing_because_unable__[]
      end

      def __stop_parsing_when_extra

        x = @_scanner.head_as_is
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
        Common_::BoundCall.via_value x
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
          Arc_::ComponentAssociation::LOOKS_LIKE_COMPOUND
        end
      end

      ROOT_ASSOCIATION___ = Root_Association____.new
    end
  end
end
