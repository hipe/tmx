module Skylab::Tabular

  class Operations_::InferTable

    class CLI

      # not sure what our requirements are for a client here yet so
      # we're gonna roll it on our own for now..

      def initialize argv, sin, sout, serr, pn_s_a

        @ARGV = argv
        @program_name_string_array = pn_s_a
        @stderr = serr
        @stdout = sout
        @stdin = sin
      end

      def execute
        if _is_interactive
          if _has_arguments
            if _parse_arguments
              if _is_finished
                SUCCESS_EXITSTATUS__
              else
                _whine_about_expecting_STDIN
              end
            else
              @_exitstatus
            end
          else
            _whine_about_expecting_STDIN
          end
        elsif _has_arguments
          if _parse_arguments
            if _is_finished
              SUCCESS_EXITSTATUS__
            else
              _send_request
            end
          else
            @_exitstatus
          end
        else
          _init_operation
          _send_request
        end
      end

      def _is_interactive
        @stdin.tty?
      end

      def _has_arguments
        @ARGV.length.nonzero?
      end

      def _is_finished

        # must be set whenever had arguments, will only be read once.
        # is how we short-circuit out of normal processing when e.g help

        remove_instance_variable :@_is_finished
      end

      def _parse_arguments

        if HELP_RX__ =~ @ARGV.first || 1 < @ARGV.length && HELP_RX__ =~ @ARGV.last
          __express_help
        else
          __do_parse_arguments
        end
      end

      def __do_parse_arguments
        _init_operation
        ok = @_operation._parse_arguments__
        if ok
          @_is_finished = false
          ok
        else
          remove_instance_variable :@_operation
          @_exitstatus = GENERIC_ERROR_EXITSTATUS__
          _express_usage_and_invite_to_help
          UNABLE_
        end
      end

      # -- consequences

      def _whine_about_expecting_STDIN
        @stderr.puts "expecting STDIN"
        _express_usage_and_invite_to_help
      end

      def __express_help

        _express_usage

        @stderr.puts

        @stderr.puts "options:"

        n = 8  # meh
        first_line_format = "  -%#{ n }s    %s"
        subsequent_line_format = "#{ SPACE_ * ( n + 7 ) }%s"

        _init_operation
        st = @_operation.__to_primary_description_stream_
        begin
          pa = st.gets
          pa || break

          p = -> line do

            p = -> line_ do
              @stderr.puts subsequent_line_format % line_
            end

            _slug = Common_::Name.via_lowercase_with_underscores_symbol(
              pa.name_x ).as_slug

            @stderr.puts first_line_format % [ _slug, line ]
          end

          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          NOTHING_.instance_exec _y, & pa.value_x  # no expag until we need one
          redo
        end while above

        @_is_finished = true
        ACHIEVED_
      end

      def _send_request
        @_operation.line_upstream = remove_instance_variable :@stdin
        @_exitstatus = SUCCESS_EXITSTATUS__
        tabler = @_operation.execute
        if tabler
          tabler.to_line_stream.each( & @stdout.method( :puts ) )
        end
        @_exitstatus
      end

      # -- highest level support

      def _init_operation

        _argv = remove_instance_variable :@ARGV

        _real_arg_scn = Common_::Polymorphic_Stream.via_array _argv

        __init_listener

        _arg_scn =
            Zerk_lib_[]::NonInteractiveCLI::MultiModeArgumentScanner.
        define do |o|
          o.user_scanner _real_arg_scn
          # o.add_primary :help, method( :_express_help ), Describe_help__
          o.emit_into @listener
        end

        @_operation = Operation___.new _arg_scn
        NIL
      end

      def __init_listener
        @listener = method :__receive_emission
        NIL
      end

      # -- emission handling

      def __receive_emission * i_a, & ev_p

        :expression == i_a.fetch( 1 ) || self._DO_ME

        if :error == i_a.first
          @_exitstatus ||= GENERIC_ERROR_EXITSTATUS__
        end

        _y = __info_yielder

        _expag = Zerk_lib_[]::NonInteractiveCLI::ArgumentScannerExpressionAgent.instance

        _expag.instance_exec @___line_yielder_for_info, & ev_p
        NIL
      end

      def __info_yielder
        @___line_yielder_for_info ||= ::Enumerator::Yielder.new do |line|
          @stderr.puts line
        end
      end

      # -- support

      def _express_usage_and_invite_to_help
        _express_usage
        __invite_to_help
      end

      def _express_usage
        @stderr.puts "usage: '(e.g) cat some-file | tab [options]'"
        NIL
      end

      def __invite_to_help
        @stderr.puts "use '#{ _program_name } -h' for help"
        GENERIC_ERROR_EXITSTATUS__
      end

      def _program_name
        ::File.basename @program_name_string_array.last
      end

      # ===

      GENERIC_ERROR_EXITSTATUS__ = 5
      HELP_RX__ = /\A--?h(?:e(?:l(?:p)?)?)?\z/
      SUCCESS_EXITSTATUS__ = 0

      # ===
    end

    # ==

    class Operation___

      # a separation from [#br-002] "modality" clients will be largely
      # artificial because of how monospace-string-centric the whole
      # stack is..

      def initialize arg_scn
        @_ = Magnetics
        @args = arg_scn
        @_listener = arg_scn.listener
      end

      def __to_primary_description_stream_
        h = OPTION_DESCRIPTIONS___
        Stream_.call h.keys do |k|
          Common_::Pair.via_value_and_name h.fetch(k), k
        end
      end

      def _parse_arguments__  # assume some FOR NOW

        matcher = @args.matcher_for :primary, :against_hash, OPTIONS___
        begin
          ok = matcher.gets
          ok || break
          ok = send ok.branch_item_value
          ok || break
        end until @args.no_unparsed_exists
        remove_instance_variable :@args
        ok
      end

      def __at_width
        @args.advance_one
        _ = @args.parse_primary_value :positive_nonzero_integer
        _store :@width, _
      end

      attr_writer(
        :line_upstream,
      )

      def execute

        @_inference = Hardcoded_inference_instance_for_now___[]
        self
      end

      def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        if x
          instance_variable_set ivar, x  ; ACHIEVED_
        else
          x
        end
      end

      # -- read

      def to_line_stream

        _mt_st = _mixed_tuple_stream = @_::
          MixedTupleStream_via_LineStream_and_Inference.
            call( @line_upstream, @_inference, & @_listener )

        _scn = @_::PageScanner_via_MixedTupleStream_and_Inference.call(  # 1x
          _mt_st, @_inference, & @_listener )

        _ = _scn.flush_to_line_stream

        _  # #todo
      end
    end

    # ==

    OPTIONS___ = {
      width: :__at_width,
    }

    OPTION_DESCRIPTIONS___ = {
      width: -> y do
        y << "jamaican me crazy"
        y << "you really are"
      end,
    }

    # ==

    Hardcoded_inference_instance_for_now___ = Lazy_.call do

      # (one day we anticipate making this configurable somehow.)

      Models_Inference___.define do |o|

        o.page_size = 2

        o.target_final_width = 40

        o.threshold_for_whether_a_column_is_numeric = 0.618  # explained fully at [#004.B]
      end
    end

    Max_share_meter_prototype___ = Lazy_.call do

      Zerk_lib_[]::CLI::HorizontalMeter.define do |o|
        o.foreground_glyph '+'
        o.background_glyph SPACE_
      end
    end

    class Models_Inference___ < SimpleModel_

      # this is a "full stack" "injector". it both provides runtime
      # parameters that are in some way variable (or not) and corrals
      # external resources (classes). this same instance threads throughout
      # many of the performers in one invocation, so that as implementation
      # details change, the centrality of this does not.

      def SECRET_MOCK_KEY= x
        @__secret_mock_key_knownness = Common_::Known_Known[ x ]
      end

      def SECRET_MOCK_KEY
        @__secret_mock_key_knownness.value_x
      end

      attr_accessor(
        :page_size,
        :target_final_width,
        :threshold_for_whether_a_column_is_numeric,  # explained fully at [#004.B]
      )

      def freeze  # only while SECRET_MOCK_KEY
        NOTHING_
      end

      def define_table__ & defn_p

        _table_lib = Zerk_lib_[]::CLI::Table

        _table_lib::Design.define do |o|

          o.separator_glyphs EMPTY_S_, SPACE_ * 2, EMPTY_S_

          defn_p[ o ]
        end
      end

      def max_share_meter_prototype__
        Max_share_meter_prototype___[]
      end
    end

    # ==

    # ==
  end
end
# #tombstone: full reconception from ancient [as]
