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
            _maybe_express_usage_and_invite_to_help
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
        @stderr.puts "synopsis: generate an ASCII table from lines of data"
        @stderr.puts
        @stderr.puts "options:"

        # #open [#007.D] we probably should not be rolling our own help screen

        _DASH = '-' ; _UNDERSCORE = '_'  # DASH_ UNDERSCORE_

        widest = 0 ; monikers = [] ; desc_procs = []
        @_operation.__to_primary_description_stream_.each do |pa|
          moniker = "-#{ pa.name_x.id2name.gsub _UNDERSCORE, _DASH }"
          len = moniker.length
          widest < len and widest = len
          monikers.push moniker ; desc_procs.push pa.value_x
        end

        moniker_only = "#{ SPACE_ * 2 }%#{ widest }s"
        first_line_format = "#{ moniker_only }#{ SPACE_ * 3 }%s"
        subsequent_line_format = first_line_format % [ nil, '%s' ]  # wee

        express_both = -> desc_p, moniker do
          subsequent_p = -> line do
            @stderr.puts subsequent_line_format % line
          end
          p = -> line do
            p = subsequent_p
            @stderr.puts first_line_format % [ moniker, line ]
          end
          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end
          NOTHING_.instance_exec _y, & desc_p  # no expag until we need one
        end

        monikers.length.times do |d|
          moniker = monikers.fetch d
          desc_p = desc_procs.fetch d

          if desc_p
            express_both[ desc_p, moniker ]
          else
            @stderr.puts moniker_only % moniker
          end
        end

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
          @_parse_error_symbol = :parse_error
          @_exitstatus = _maybe_express_usage_and_invite_to_help
          UNABLE_
        else
          stdin
        end
      end

      # -- emission handling

      def __receive_emission * i_a, & ev_p

        :expression == i_a.fetch( 1 ) || self._DO_ME

        if :error == i_a.first
          @_parse_error_symbol = i_a.fetch 2
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

      def _maybe_express_usage_and_invite_to_help

        usage = true ; invite = true
        case @_parse_error_symbol

        when :primary_parse_error
          # then a specific message was already emitted
          usage = false

        when :parse_error
          # full monty

        else
          self._DECIDE_ME
        end

        usage and _express_usage
        invite and __invite_to_help
        GENERIC_ERROR_EXITSTATUS__
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
        @page_size = nil
        @separators = nil
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
          ok = send ok.branch_item_value
          ok || break
        end until @_args.no_unparsed_exists
        ok
      end

      OPTIONS___ = {
        left_separator: :_at_separator,
        line_upstreamer: :__at_line_upstreamer,  # justified at #here-1
        inner_separator: :_at_separator,
        mixed_tuple_upstream: :__at_mixed_tuple_upstream,
        page_size: :__at_page_size,
        right_separator: :_at_separator,
        width: :__at_width,
      }

      OPTION_DESCRIPTIONS___ = {

        width: -> y do
          y << "jamaican me crazy"
          y << "(default: #{ TARGET_WIDTH___ })"
        end,

        page_size: -> y do
          y << "how many tuples (rows) are read before a page"
          y << "(and visualizations) are flushed (default: #{ PAGE_SIZE___ })."
        end,

        left_separator: -> y do
          y << "default: #{ Left_separator__[].inspect }"
        end,

        inner_separator: -> y do
          y << "default: #{ Inner_separator__[].inspect }"
        end,

        right_separator: -> y do
          y << "default: #{ Right_separator__[].inspect }"
        end,
      }

      def _at_separator
        _which = @_args.current_primary_symbol
        @_args.advance_one
        x = @_args.head_as_is
        @_args.advance_one
        d = case _which
        when :left_separator ; 0
        when :inner_separator ; 1
        when :right_separator ; 2
        else self._SANITY
        end
        ( @separators ||= [] )[ d ] = x
        ACHIEVED_
      end

      def __at_line_upstreamer
        @_args.advance_one
        x = @_args.parse_primary_value :must_be_trueish
        x and _receive_MTUer x, :__mixed_tuple_upstream_via_line_upstreamer
      end

      def __at_mixed_tuple_upstream
        @_args.advance_one
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

      def __at_width
        @_args.advance_one
        _ = @_args.parse_primary_value :must_be_integer_that_is_positive_nonzero
        _store :@width, _
      end

      def __at_page_size

        @_args.advance_one

        min = PAGE_SIZE_MINIMUM__

        _d = @_args.parse_primary_value :must_be_integer, :must_be do |d, o|
          if min <= d
            d
          else
            o.primary_parse_error :custom_int_range do |y|
              _ = o.subject_moniker
              y << "#{ _ } must be at least #{ min } (had #{ d })"
            end
          end
        end

        _store :@page_size, _d
      end

      def execute

        @_inference = Models_Inference___.define do |o|

          o.separators = @separators  # nil OK

          o.target_final_width = @width || TARGET_WIDTH___

          o.page_size = @page_size || PAGE_SIZE___

          o.threshold_for_whether_a_column_is_numeric =
            NUMERIC_COLUMN_THRESHOLD___
        end

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

      def initialize
        @separators = nil
        super
      end

      attr_accessor(
        :page_size,
        :separators,
        :target_final_width,
        :threshold_for_whether_a_column_is_numeric,  # explained fully at [#004.B]
      )

      def define_table_design__ & defn_p

        a = [ * @separators ]
        a[ 0 ] ||= Left_separator__[]
        a[ 1 ] ||= Inner_separator__[]
        a[ 2 ] ||= Right_separator__[]

        _table_lib = Zerk_lib_[]::CLI::Table

        _table_lib::Design.define do |o|

          o.separator_glyphs( * a )

          defn_p[ o ]
        end
      end

      def max_share_meter_prototype__
        Max_share_meter_prototype___[]
      end
    end

    # ==

    Left_separator__ = -> { EMPTY_S_ }
    Inner_separator__ = Lazy_.call { SPACE_ * 2 }
    Right_separator__ = -> { EMPTY_S_ }

    # ==

    NUMERIC_COLUMN_THRESHOLD___ = 0.618  # explained fully at [#004.B]
    PAGE_SIZE___ = 8  # don't test around this
    PAGE_SIZE_MINIMUM__ = 2
    TARGET_WIDTH___ = 40  # not sure if we test around this

    # ==
  end
end
# #tombstone: full reconception from ancient [as]
