module Skylab::Zerk

  class NonInteractiveCLI

    class OptionParserController  # see [#015]

      # implement exactly the :#"algorithm".
      #

      def initialize custom_op_p, oi

        @_operation_index = oi
        @_stdlib_op_lib = Home_.lib_.stdlib_option_parser  # see #note-1

        if custom_op_p
          @_op = custom_op_p[ oi.stack_frame_ ]
        else
          @_op = Build___.new( @_operation_index, @_stdlib_op_lib ).execute
        end
      end

      def parse__ argv, client, & pp
        Parse___.new( argv, @_op, @_operation_index, client, @_stdlib_op_lib, & pp ).execute
      end

      def the_option_parser__  # just for help
        @_op
      end

      class Build___

        def initialize oi, stdl
          @_operation_index = oi
          @_stdlib_op_lib = stdl
        end

        def execute

          @_op = @_stdlib_op_lib.new

          __commmon_init

          oi = @_operation_index

          a = oi.__release_bespokes_to_add_to_op

          bx = oi.release_primitivesque_appropriation_op_box__

          if a || ( bx && bx.length.nonzero? )

            # box could have been emptied at #spot-3 :#here-1

            __work a, bx
          end

          @_op
        end

        def __commmon_init

          # init shorts

          shorts = ::Hash.new do |h, k|
            h[ k ] = false ; true
          end
          shorts[ H__ ] = false  # never use this one
          @__shorts = shorts

          # add help option

          @_op.on SHORT_HELP_OPTION, '--help[=named-argument]' do |s|
            SpecialDirective.new s, :help
          end
          NIL
        end

        H__ = 'h'

      #== BEGIN old "build"

      def __work a, bx  # assume one or both

        @_expag = @_operation_index.root_frame__.CLI.expression_agent  # :#spot-1
        @_scope_index = @_operation_index.scope_index_

        if bx
          bx.each_value do |d|
            @_asc = @_scope_index.scope_node_( d ).association
            send SINGPLUR___.fetch @_asc.singplur_category
          end
          remove_instance_variable :@_asc  # hello #here-1
        end

        if a
          a.each do |par|
            __add_this_bespoke_parameter_to_op par
          end
        end

        remove_instance_variable :@_expag
        remove_instance_variable :@_scope_index ; nil
      end

      SINGPLUR___ = {
        :singular_of => :__add_this_singular_primi_approp_to_op,
        # (no :plural_of by design)
        nil => :_add_this_primitivesque_appropriation_to_op,
      }

      def __add_this_singular_primi_approp_to_op
        # (hi.)
        _add_this_primitivesque_appropriation_to_op
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

      def _add_this_primitivesque_appropriation_to_op

        # (this fulfills [#] note B in the algorithm)

        asc = @_asc  # necessary - will close on it

        _s_a = _any_desc_lines_for asc.description_proc  # help only

        slug, short = _slug_and_any_short_for asc.name

        sym = asc.argument_arity
        if sym && :zero == sym  # [ac] is agnostic, so we default this late,
          # ..rather than Field_::Takes_argument[ asc ]
          _long = "--#{ slug }"
        else
          _long = "--#{ slug } #{ OPTION_ARGUMENT_MONIKER__ }"
        end

        @_op.on( * short, _long, * _s_a ) do |s|
          Assignment.new s, asc  # was Primitivesque_Invocation___
        end
        NIL_
      end

      def __add_this_bespoke_parameter_to_op par

        _s_a = _any_desc_lines_for par.description_proc  # help only

        slug, short = _slug_and_any_short_for par.name

        if Field_::Takes_argument[ par ]

          _ = par.argument_argument_moniker || OPTION_ARGUMENT_MONIKER__

          _long = "--#{ slug } #{ _ }"
        else

          _long = "--#{ slug }"
        end

        @_op.on( * short, _long, * _s_a ) do |s|
          Assignment.new s, par
        end
        NIL_
      end

      OPTION_ARGUMENT_MONIKER__ = 'X'

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
      #== END
      end

      # ==

      class Parse___

        def initialize argv, op, oi, client, op_lib, & pp
          @_argv = argv
          @client = client
          @__oes_pp = pp
          @__oi = oi
          @__op = op
          @__op_lib = op_lib
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
            @client.when_via_option_parser_parse_error__ @_parse_error

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

          # [#015] :#public-API:Point-1: the `parse_in_order` signature below

          # because it's of an arguably better design (separating formal
          # structure from invocation-time event handling), we circumvent
          # stdlib o.p's published interface and use its private method,
          # at the cost of a greater chance of future pain.. #"c3"

          _setter = -> _normal_slug, invo do

            if invo.is_special
              _m = AVALABLE_SPECIAL_DIRECTIVES___.fetch invo.__method_name
              send _m, * invo.__argument_array
            else
              ___receive invo._to_qkn
            end
          end

          begin
            @__op.send :parse_in_order, @_argv, _setter do |non_opt|
              @_had_non_opts = true
              ( @__non_opts ||= [] ).push non_opt ; nil
            end
          rescue @__op_lib::ParseError => e
            @_had_parse_error = true
            @_parse_error = e
          end
          NIL_
        end

        AVALABLE_SPECIAL_DIRECTIVES___ = {
          help: :__receive_help,
          parse_error: :_receive_mixed_parse_error,
          parse_error_event: :_receive_mixed_parse_error,
          parse_error_expression: :_receive_mixed_parse_error,
        }

        def _receive_mixed_parse_error x
          @_had_parse_error = true
          @_parse_error = x ; nil
        end

        def __receive_help s
          @_help_was_requested = true
          @_help_s = s ; nil
        end

        def ___receive qk  # (thoughts on availability.. #"c4")

          ok = Receive_ARGV_value_.new( qk, @__oi, @client, :_TEMP_VIA_OPTS_, & @__oes_pp ).execute

          if ! ok
            # (because of the way o.p is, we can't elegantly signal a stop)
            @_component_rejected_request = true
            @__component_build_value_result = ok
          end
          NIL_
        end
      end

      # ==

      class SpecialDirective

        def initialize *args, sym
          @__argument_array = args
          @__method_name = sym
        end

        attr_reader(
          :__argument_array,
          :__method_name,
        )

        def is_special
          true
        end
      end

      # ==

      class Assignment

        def initialize any_value_s, form
          @__any_value_string = any_value_s
          @__association_or_parameter = form
        end

        def _to_qkn
          Common_::Qualified_Knownness[ @__any_value_string, @__association_or_parameter ]
        end

        def is_special
          false
        end
      end
    end
  end
end
