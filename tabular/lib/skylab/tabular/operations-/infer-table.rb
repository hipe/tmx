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

        __init_operation

        if __match_help
          __express_help
        else
          if @_operation.parse_arguments_for_operation_
            __send_request
          else
            _express_usage_and_invite_to_help
          end
        end
      end

      def __match_help
        argv = remove_instance_variable :@ARGV
        argv.length.nonzero? and
          HELP_RX__ =~ argv.first ||
          1 < argv.length && HELP_RX__ =~ argv.last
      end

      # -- consequences

      def __express_help

        _express_usage

        @stderr.puts

        @stderr.puts "options:"

        n = 8  # meh
        first_line_format = "  -%#{ n }s    %s"
        subsequent_line_format = "#{ SPACE_ * ( n + 7 ) }%s"

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

        SUCCESS_EXITSTATUS__
      end

      def __send_request
        @_exitstatus = SUCCESS_EXITSTATUS__
        tabler = @_operation.execute
        if tabler
          st = tabler.to_line_stream
          if st
            st.each( & @stdout.method( :puts ) )
          end
        end
        @_exitstatus
      end

      # -- highest level support

      def __init_operation

        @listener = method :__receive_emission

        _real_arg_scn = Common_::Polymorphic_Stream.via_array @ARGV

        _line_upstreamer = method :__procure_line_upstream

        _arg_scn =
            Zerk_lib_[]::NonInteractiveCLI::MultiModeArgumentScanner.
        define do |o|

          o.user_scanner _real_arg_scn

          o.subtract_primary :line_upstreamer, _line_upstreamer

          o.subtract_primary :mixed_tuple_upstream

          o.emit_into @listener
        end

        @_operation = Operation___.begin_operation_ _arg_scn
        NIL
      end

      def __procure_line_upstream

        # error messages emitted by plain old argument parsing are generally
        # easier to understand than those emitted here; so for those cases
        # where errors from both categories would occur, we want that the
        # easier to understand messages get precedence over this one.
        #
        # as a hack to realize this desired effect of precedence, we take
        # a `line_upstreamer` instead of a `line_upstream` which allows us
        # to defer the resolution of the line upstream to after the parsing
        # of the other individual arguments.
        #
        # also, in a hypothetical world where we accept a filename as a
        # means to a line upstream, we would likewise want to defer the
        # validation of the line upstream until later than the first-pass
        # of argument normalization. :#here-1

        stdin = remove_instance_variable :@stdin  # always and only ever here
        if stdin.tty?
          @stderr.puts "expecting STDIN"
          @_exitstatus = _express_usage_and_invite_to_help
          UNABLE_
        else
          stdin
        end
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

    Operation___ = self
    class Operation___

      # the degree to which this operation is decoupled from one or another
      # (read: CLI) [#br-002] "modality" client is in flux:
      #
      # presently input decoupling is good i.e this can process an
      # "upstream" in both a CLI-centric and API-centric ways (namely,
      # line upstream and mixed tuple upstream respectively).
      #
      # decoupling for output, however, has only the groundwork laid.
      # because there is presently no way to express a table into any
      # modality other than CLI, the point would be fully moot were it not
      # for it being an #exercise in architecture.

      class << self
        alias_method :begin_operation_, :new
        undef_method :new
      end  # >>

      def initialize arg_scn

        @_ = Magnetics
        @_has_MTUer = false
        @_listener = arg_scn.listener
        @_receive_MTUer = :__receive_MTUer_initially
        @_args = arg_scn
        @width = nil
      end

      def __to_primary_description_stream_
        h = OPTION_DESCRIPTIONS___
        Stream_.call h.keys do |k|
          Common_::Pair.via_value_and_name h.fetch(k), k
        end
      end

      def parse_arguments_for_operation_
        if __process_arguments
          __normalize
        end
      end

      def __normalize
        if @_has_MTUer
          ACHIEVED_
        else
          @_listener.call :error, :expression, :missing_required_parameter do |y|
            y << "must have a mixed tuple upstream means (e.g `line_upstreamer`)"  # meh
          end
          UNABLE_
        end
      end

      def __process_arguments
        ok = if @_args.no_unparsed_exists
          ACHIEVED_
        else
          __parse_some_arguments
        end
        remove_instance_variable :@_args
        ok
      end

      def __parse_some_arguments

        matcher = @_args.matcher_for :primary, :against_hash, OPTIONS___
        begin
          ok = matcher.gets
          ok || break
          @_args.advance_one
          ok = send ok.branch_item_value
          ok || break
        end until @_args.no_unparsed_exists
        ok
      end

      OPTIONS___ = {
        line_upstreamer: :__parse_line_upstreamer,  # justified at #here-1
        mixed_tuple_upstream: :__parse_mixed_tuple_upstream,
        width: :__parse_width,
      }

      OPTION_DESCRIPTIONS___ = {
        width: -> y do
          y << "jamaican me crazy"
          y << "you really are"
        end,
      }

      def __parse_line_upstreamer
        x = @_args.parse_primary_value :must_be_trueish
        x and _receive_MTUer x, :__mixed_tuple_upstream_via_line_upstreamer
      end

      def __parse_mixed_tuple_upstream
        us = @_args.parse_primary_value :must_be_trueish
        us and _receive_MTUer us, :__mixed_tuple_upstream_via_same
      end

      def _receive_MTUer x, m
        send @_receive_MTUer, x, m
      end

      def __receive_MTUer_initially x, m
        @_has_MTUer = true
        @_receive_MTUer = :_COVER_ME__sanity_check__wont_overwrite_multiple_argument_values__  # #todo
        @__MTU_method_name = m
        @_MTU_value = x
        ACHIEVED_
      end

      def __parse_width
        _ = @_args.parse_primary_value :integer_that_is_postive_nonzero
        _store :@width, _
      end

      def execute
        @_inference = Inference_via___[ @width ]
        # (all the money is in `to_line_stream` etc)
        self
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- read

      def to_line_stream

        x = send @__MTU_method_name

        x &&= @_::PageScanner_via_MixedTupleStream_and_Inference.call(  # 1x
          x, @_inference, & @_listener )

        x &&= x.flush_to_line_stream

        x  # #todo
      end

      def __mixed_tuple_upstream_via_line_upstreamer

        _proc = remove_instance_variable :@_MTU_value
        io = _proc.call
        if io
          _ = @_::MixedTupleStream_via_LineStream_and_Inference.
            call( io, @_inference, & @_listener )
          _  # #todo
        end
      end

      def __mixed_tuple_upstream_via_same
        remove_instance_variable :@_MTU_value
      end
    end

    # ==

    Inference_via___ = -> width do

      Models_Inference___.define do |o|

        o.page_size = 2

        o.target_final_width = width || 40

        o.threshold_for_whether_a_column_is_numeric = 0.618  # explained fully at [#004.B]
      end
    end

    Max_share_meter_prototype___ = Lazy_.call do

      Zerk_lib_[]::CLI::HorizontalMeter.define do |o|
        o.foreground_glyph '+'
        o.background_glyph SPACE_
      end
    end

    class Models_Inference___ < SimpleModel_  # #testpoint, too

      # this is a "full stack" "injector". it both provides runtime
      # parameters that are in some way variable (or not) and corrals
      # external resources (classes). this same instance threads throughout
      # many of the performers in one invocation, so that as implementation
      # details change, the centrality of this does not.

      attr_accessor(
        :page_size,
        :target_final_width,
        :threshold_for_whether_a_column_is_numeric,  # explained fully at [#004.B]
      )

      def define_table_design__ & defn_p

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
