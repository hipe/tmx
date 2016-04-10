module Skylab::Zerk

  class NonInteractiveCLI

    class Option_Parser_Controller___  # see [#015]

      # implement exactly the :#"algorithm".
      #

      def initialize oi

        @_operation_index = oi
        __assemble_op
      end

      def parse__ argv, client, & pp
        Parse___.new( argv, @_op, @_operation_index, client, & pp ).execute
      end

      def the_option_parser__  # just for help
        @_op
      end

      def __assemble_op

        __begin_option_parser

        shorts = ::Hash.new do |h, k|
          h[ k ] = false ; true
        end
        shorts[ 'h' ] = false  # never use this one
        @__shorts = shorts

        oi = @_operation_index

        a = oi.__release_bespokes_to_add_to_op
        bx = oi.release_primitivesque_appropriation_op_box__

        if bx && bx.length.zero?
          bx = nil  # could have been emptied at #spot-3
        end

        if a || bx
          ___populate_option_parser_with_something a, bx
        end
        NIL_
      end

      def ___populate_option_parser_with_something a, bx  # assume one or both

        @_expag = @_operation_index.root_frame__.CLI.expression_agent  # :#spot-1
        @_scope_index = @_operation_index.scope_index_

        if bx
          bx.each_value do |d|
            __add_this_primitivesque_appropriation_to_op d
          end
        end

        if a
          a.each do |par|
            __add_this_bespoke_parameter_to_op par
          end
        end

        remove_instance_variable :@_expag
        remove_instance_variable :@_scope_index ; nil
      end

      # == BEGIN:
      #
      # after the below issues, then de-dup the duplication happening..
      # #open [#019] flags in o.p. #open [#020] argument monikers
      #
      # for now we add a description (if any) to these items regardless
      # of whether this is a "didactic" option parser or a parsing one.
      # this comes at a cost to invocations that don't result in help,
      # but with  mental savings of having only one option parser.

      def __add_this_primitivesque_appropriation_to_op d

        # (this fulfills [#] note B in the algorithm)

        nt = @_scope_index.scope_node_ d

        _s_a = _any_desc_lines_for nt.association.description_proc  # help only

        slug, short = _slug_and_any_short_for nt.name

        asc = nt.association

        sym = asc.argument_arity
        if sym && :zero == sym  # [ac] is agnostic, so we default this late,
          # ..rather than Field_::Takes_argument[ asc ]
          _long = "--#{ slug }"
        else
          _long = "--#{ slug } X"
        end

        @_op.on( * short, _long, * _s_a ) do |s|
          Primitivesque_Invocation___.new s, asc
        end
        NIL_
      end

      def __add_this_bespoke_parameter_to_op par

        _s_a = _any_desc_lines_for par.description_proc  # help only

        slug, short = _slug_and_any_short_for par.name

        if Field_::Takes_argument[ par ]
          _long = "--#{ slug } X"
        else
          _long = "--#{ slug }"
        end

        @_op.on( * short, _long, * _s_a ) do |s|
          Bespoke_Invocation___.new s, par
        end
        NIL_
      end

      def _any_desc_lines_for desc_p
        if desc_p
          @_expag.calculate [], & desc_p
        end
      end

      def _slug_and_any_short_for nf

        slug = nf.as_slug

        char = slug[ 0 ]

        if @__shorts[ char ]
          _short_sw = "-#{ char }"
        end

        [ slug, _short_sw ]
      end

      # == END

      def __begin_option_parser

        op = Home_.lib_.stdlib_option_parser.new

        op.on '-h', '--help[=named-argument]' do |s|
          Special_Invocation___.new s, :__receive_help
        end

        @_op = op ; nil
      end

      # ==

      class Parse___

        def initialize argv, op, oi, client, & pp
          @_argv = argv
          @client = client
          @__oes_pp = pp
          @__oi = oi
          @__op = op
        end

        def execute

          # (we tried this with a single-case-only logic, but no:)

          @_component_rejected_request = false
          @_had_parse_error = false
          @_had_non_opts = false
          @_help_was_requested = false

          ___parse

          # (here we in effect choose for the client the priority of these:)

          if @_had_parse_error
            @client.when_via_option_parser_parse_error__ @__parse_error

          elsif @_component_rejected_request
            @client.when_via_option_parser_component_rejected_request__

          elsif @_help_was_requested
            @client.when_via_option_parser_help_was_requested__ @_help_s

          else

            if @_had_non_opts
              @_argv.concat @__non_opts  # among other means
            end

            KEEP_PARSING_
          end
        end

        def ___parse

          # because it's of an arguably better design (separating formal
          # structure from invocation-time event handling), we circumvent
          # stdlib o.p's published interface and use its private method,
          # at the cost of a greater chance of future pain.. #"c3"

          _setter = -> _normal_slug, invo do

            if invo.is_special
              send invo.method_name, invo.argument_string
            else
              ___receive invo._to_qkn
            end
          end

          begin
            @__op.send :parse_in_order, @_argv, _setter do |non_opt|
              @_had_non_opts = true
              ( @__non_opts ||= [] ).push non_opt ; nil
            end
          rescue ::OptionParser::ParseError => e
            @_had_parse_error = true
            @__parse_error = e
          end
          NIL_
        end

        def ___receive qk  # (thoughts on availability.. #"c4")

          ok = Receive_ARGV_value_.new( qk, @__oi, @client, & @__oes_pp ).execute

          if ! ok
            # (because of the way o.p is, we can't elegantly signal a stop)
            @_component_rejected_request = true
            @__component_build_value_result = ok
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

      # ==

      class Bespoke_Invocation___

        def initialize any_value_s, par
          @any_value_s = any_value_s
          @parameter = par
        end

        def _to_qkn
          Callback_::Qualified_Knownness[ @any_value_s, @parameter ]
        end

        def is_special
          false
        end
      end

      class Primitivesque_Invocation___

        def initialize any_value_s, asc
          @any_value_s = any_value_s
          @association = asc
        end

        def _to_qkn
          Callback_::Qualified_Knownness[ @any_value_s, @association ]
        end

        def is_special
          false
        end
      end
    end
  end
end
