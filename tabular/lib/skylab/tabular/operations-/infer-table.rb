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
        subsequent_line_format = "#{ ' ' * ( n + 7 ) }%s"

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
        ok = __resolve_mixed_tuple_stream_via_line_stream
        ok &&= __resolve_page_survey_via_mixed_tuple_stream
        ok &&= __resolve_table_design_via_page_survey
        ok && finish
      end

      def __resolve_table_design_via_page_survey
        ACHIEVED_
      end

      def __resolve_page_survey_via_mixed_tuple_stream
        ACHIEVED_
      end

      def __resolve_mixed_tuple_stream_via_line_stream
        ACHIEVED_
      end

      def finish
        # (this little clump of mockiness will definitely move around..)

        first_line = @line_upstream.gets
        if first_line
          _matchdata = %r(\Asecret-mock-key-([-a-z0-9A-Z_.]+)).match first_line
          @__mock_method_name = MOCKS__.fetch _matchdata[1]
          self
        else
          @_listener.call :info, :expression, :no_lines_in_input do |y|
            y << "(no lines in input. done.)"
          end
          NOTHING_
        end
      end

      MOCKS__ = {
        '1' => :__the_first_mock,
      }

      def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        if x
          instance_variable_set ivar, x  ; ACHIEVED_
        else
          x
        end
      end

      # -- read

      def to_line_stream
        send @__mock_method_name
      end

      def __the_first_mock
        _a = [
          "secret-mock-key-1    32  +++++++++++++++",
          "an-other-alterative  16  +++++++        ",
        ]
        Stream_[ _a ]
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

    Lazy_ = Common_::Lazy
    Zerk_lib_ = Lazy_.call do
      Home_.lib_.zerk
    end

    # ==

    ACHIEVED_ = true
    UNABLE_ = false

    # ==
  end
end
# #tombstone: full reconception from ancient [as]
