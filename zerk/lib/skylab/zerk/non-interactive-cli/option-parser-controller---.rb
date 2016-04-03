module Skylab::Zerk

  class NonInteractiveCLI

    class Option_Parser_Controller___  # many code-notes in [#015]

      # we would normally break this up into smaller pieces (one that builds
      # the o.p, another that runs its against the input) but because under
      # #[#ac-002]:DT3 everything is dynamic, there is not much room to
      # cache any of this work..

      # see "our main argument is.."

      def initialize fo_frame, session, & pp

        __init_option_parser
        @_fo_frame = fo_frame
        __populate_option_parser
        # --
        @_oes_pp = pp
        @_selection_stack = @_fo_frame.formal_operation_.selection_stack
        @_session = session
      end

      # --

      def parse__ argv

        # (we tried this with a single-case-only logic, but no:)

        @_component_rejected_request = false
        @_had_parse_error = false
        @_had_non_opts = false
        @_help_was_requested = false

        ___parse argv

        # (here we in effect choose for the client the priority of these:)

        if @_had_parse_error
          @_session.when_via_option_parser_parse_error__ @__parse_error

        elsif @_component_rejected_request
          @_session.when_via_option_parser_component_rejected_request__

        elsif @_had_non_opts
          @_session.when_via_option_parser_extra_args__ @__non_opts

        elsif @_help_was_requested
          @_session.when_via_option_parser_help_was_requested__ @_help_s

        else
          KEEP_PARSING_
        end
      end

      def ___parse argv

        # because it's of an arguably better design (seaprating formal
        # structure from invocation-time event handling), we circumvent
        # stdlib o.p's published interface and use its private method,
        # at the cost of a greater chance of future pain.

        _setter = -> _normal_slug, invo do
          if invo.is_special
            send invo.method_name, invo.argument_string
          else
            ___receive( * invo.to_a )
          end
        end

        begin
          @_op.send :parse_in_order, argv, _setter do |non_opt|
            @_had_non_opts = true
            ( @__non_opts ||= [] ).push non_opt ; nil
          end
        rescue ::OptionParser::ParseError => e
          @_had_parse_error = true
          @__parse_error = e
        end
        NIL_
      end

      def ___receive s, asc, frame

        # "thoughts on availability.."

        p = asc.unavailability_proc

        if p
          unava_p = p[ asc ]
        end
        if unava_p
          self._WAHOO_this_will_be_fun_for_open  # #open [#022]
        end

        _st = Home_.lib_.fields::Argument_stream_via_value[ s ]

        _oes_pp = -> _ do
          # the model doesn't know the component's asssociation but we do:
          @_oes_pp[ asc ]
        end

        qk = ACS_::Interpretation::Build_value.call(
          _st,
          asc,
          frame.ACS,
          & _oes_pp
        )

        if qk
          frame.reader_writer_.write_value qk
        else
          # (because of the way o.p is, we can't elegantly signal a stop)
          @_component_rejected_request = true
          @__component_build_value_result = qk
        end
        NIL_
      end

      def __receive_help s

        @_help_was_requested = true
        @_help_s = s
        # (hack - don't overwrite an already set response; e.g if a component
        # rejected a request. the only wa this can work is if this is the only
        # place we do this, otherwise we have to go back to an if-else chain)
        NIL_
      end

      # --

      def __init_option_parser

        op = Home_.lib_.stdlib_option_parser.new

        op.on '-h', '--help[=named-argument]' do |s|
          Special_Invocation___.new s, :__receive_help
        end

        @_op = op ; nil
      end

      def __populate_option_parser

        # work backwards from the topmost frame
        #
        #   • in case we do something clever with scope and "closeness"..
        #
        #   • so that the order of the options has the options more closely
        #     associated with the operation appearing higher on the screen

        seen_h = ::Hash.new { |h,k| h[k] = true ; false }
        see = -> k do
          if seen_h[ k ]
            fail __say_seen k
          end
        end

        fr_st = @_fo_frame.to_frame_stream_from_top_

        fr_st.gets  # skip the formal operation frame itself

        frame = fr_st.gets  # there is always at least a root frame

        begin
          st = frame.to_association_stream_for_option_parser___
          begin
            asc = st.gets
            asc or break
            see[ asc.name_symbol ]
            __express_atomesque_into_optionparser asc, frame
            redo
          end while nil

          frame = fr_st.gets
        end while frame

        NIL_
      end

      def ___say_seen k
        "cannot isomorph option parser - multiple associations named #{
          }'#{ k }' (but if support for this is desired, this is [#018])"
      end

      def __express_atomesque_into_optionparser asc, frame

        # go thru normal validation when you accept values off the o.p
        # #open [#019] flags in o.p. #open [#020] argument monikers

        @_op.on "--#{ asc.name.as_slug } X" do |s|

          Attribute_Invocation___.new s, asc, frame
        end

        NIL_
      end

      # ==

      class Special_Invocation___

        def initialize s, sym
          @argument_string = s
          @method_name = sym
        end

        attr_reader(
          :argument_string,
          :method_name,
        )

        def is_special
          true
        end
      end

      class Attribute_Invocation___

        def initialize * a
          @to_a = a
        end

        attr_reader(
          :to_a,
        )

        def is_special
          false
        end
      end
    end
  end
end
