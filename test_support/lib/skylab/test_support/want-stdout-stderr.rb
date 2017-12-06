# frozen_string_literal: true

module Skylab::TestSupport

  module Want_Stdout_Stderr  # lots of "theory" in [#029]

    # NOTE this mutates strings under "oldchool" techniques! (see [#]scope )
    # assumes {  @IO_spy_group_for_want_stdout_stderr | your own `flush_baked_emission_array` }

    module Test_Context_Instance_Methods

      # -- freeze an invocation as a shared state [#here.A]

      def flush_invocation_to_help_screen_oriented_state  # current favorite

        _state = flush_frozen_state_from_want_stdout_stderr

        help_screen_oriented_state_via_invocation_state _state
      end

      def help_screen_oriented_state_via_invocation_state state  # [y2]

        _cls = _want_section::Help_Screen_State

        _cls.via :state, state, :stream, :e
      end

      def flush_invocation_to_help_screen_tree

        _state = flush_frozen_state_from_want_stdout_stderr

        _want_section.tree_via :state, _state, :stream, :e
      end

      define_method :_want_section, ( Lazy_.call do
        Home_.lib_.zerk.test_support::CLI::Want_Section_Fail_Early
      end )

      def flush_frozen_state_from_want_stdout_stderr

        remove_instance_variable :@invocation

        Frozen_State___.new(
          remove_instance_variable( :@exitstatus ),
          release_lines_for_want_stdout_stderr,
        ).freeze
      end

      def flush_baked_emission_array  # :+#hook-near #universal
        release_lines_for_want_stdout_stderr
      end

      def release_lines_for_want_stdout_stderr
        _ = remove_instance_variable :@IO_spy_group_for_want_stdout_stderr
        _.release_lines
      end

      # -- optional support for "full stack" CLI testing

      def using_want_stdout_stderr_invoke_via_argv a  # might mutate arg

        using_want_stdout_stderr_invoke_via(
          :mutable_argv, a,
          :prefix, argv_prefix_for_want_stdout_stderr,
        )
      end

      def argv_prefix_for_want_stdout_stderr  # #hook-in:1
        NIL_
      end

      def using_want_stdout_stderr_invoke_with_no_prefix * argv

        using_want_stdout_stderr_invoke_via(
          :mutable_argv, argv,
          :prefix, nil,
        )
      end

      def using_want_stdout_stderr_invoke_via * x_a
        using_want_stdout_stderr_invoke_via_iambic x_a
      end

      def using_want_stdout_stderr_invoke_via_iambic x_a

        opt = Options___.new
        x_a.each_slice 2 do | k, x |
          opt[ k ] = x
        end
        mutable_argv, prefix = opt.to_a

        if prefix
          mutable_argv[ 0, 0 ] = prefix
        end

        init_invocation_for_want_stdout_stderr mutable_argv

        path = working_directory_for_want_stdout_stderr
        if path
          orig_pwd = ::Dir.pwd
          do_debug and debug_IO.puts "cd #{ path }"
          ::Dir.chdir path
        end

        @exitstatus = @invocation.execute

        if orig_pwd
          do_debug and debug_IO.puts "cd #{ orig_pwd }"
          ::Dir.chdir orig_pwd
        end

        NIL
      end

      def working_directory_for_want_stdout_stderr
        NOTHING_
      end

      Options___ = ::Struct.new :mutable_argv, :prefix

      def init_invocation_for_want_stdout_stderr argv

        g = __build_IO_spy_group_for_want_stdout_stderr
        @IO_spy_group_for_want_stdout_stderr = g

        _s_a = invocation_strings_for_want_stdout_stderr  # #hook-out:1

        args = [ argv, * g.values_at( :i, :o, :e ), _s_a ]

        x = self.CLI_options_for_want_stdout_stderr
        if x
          if x.respond_to? :call
            use_p = x
          else
            args.concat x
          end
        end

        invo = build_invocation_for_want_stdout_stderr( * args, & use_p )

        if instance_variable_defined? :@for_want_stdout_stderr_prepare_invocation
          @for_want_stdout_stderr_prepare_invocation[ invo ]
        else
          prepare_subject_CLI_invocation invo
        end

        @invocation = invo

        NIL
      end

      def build_invocation_for_want_stdout_stderr argv, sin, sout, serr, pn_s_a, * xtra, & p

        subject_CLI.new( argv, sin, sout, serr, pn_s_a, * xtra, & p )  # #hook-out
      end

      def __build_IO_spy_group_for_want_stdout_stderr

        g = Home_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug  # :+#hook-out
        end

        g.debug_IO = debug_IO  # :+#hook-out

        g.add_stream :i, ( stdin_for_want_stdout_stderr || :__instream_not_used_yet__ )

        g.add_stream :o

        io = stderr_for_want_stdout_stderr
        if io
          g.add_stream :e, io
        else
          g.add_stream :e
        end
        g
      end

      attr_accessor :IO_spy_group_for_want_stdout_stderr, :invocation  # for hax

      alias_method :init_invocation_for_want_stdout_stderr_,
        :init_invocation_for_want_stdout_stderr  # for hax

      attr_reader :stdin_for_want_stdout_stderr,  # :+#hook-in
        :stderr_for_want_stdout_stderr

      def CLI_options_for_want_stdout_stderr
        NIL_
      end

    private

      def prepare_subject_CLI_invocation _  # #hook-in
        NIL_
      end

      # -- the newschool way

      def be_line * x_a, & x_p

        match_ Expectation.via_args( x_a, & x_p )
      end

      def match_ expectation  # (we don't love the name)

        expectation.to_matcher_bound_to self
      end

      def expectation * x_a, & x_p

        Expectation.via_args x_a, & x_p
      end

      # -- the oldschool way - expectations are executed by the test context

      def on_stream stream_symbol

        # before the expectation, set default behavior

        @__sout_serr_default_stream_symbol__ = stream_symbol ; nil
      end

      # ~ simple expect "macros"

      def want_header_line s
        want :styled, s  # no expectation of colons here, because [#072]
      end

      # ~ want (née "expect")

      def want * x_a, & p

        want_stdout_stderr_via_arglist x_a, & p
      end

      def want_stdout_stderr_via_arglist x_a, & p

        want_stdout_stderr_via Expectation.via_args( x_a, & p )
      end

      def want_stdout_stderr_via exp  # underwent big changes at tombstone-A.2

        @__sout_serr_is_baked__ ||= _bake_sout_serr
        if @__sout_serr_actual_scanner__.no_unparsed_exists
          msg = 'expected an emission, had none'
          _fail_with_message_TS { msg }
        else
          __when_some_emissions_TS_SOUT_SERR exp
        end
      end

      def __when_some_emissions_TS_SOUT_SERR exp
        scn = @__sout_serr_actual_scanner__
        _em = scn.head_as_is
        matcher = exp.to_matcher_bound_to self
        ok_x = matcher.matches? _em
        p = exp.receive_unstyled_string
        if ok_x && p
          ok_x = p[ matcher._fully_normal_string ]
        end
        if ok_x
          scn.advance_one
          ok_x
        elsif respond_to? :quickie_fail_with_message_by  # #here2
          UNABLE_  # already emitted
        else
          ::Kernel._COVER_RSPEC_LYFE  # #todo - maybe never hits
        end
      end

      # ~ for the end

      def want_fail
        want_no_more_lines
        want_result_for_failure
      end

      def want_succeed
        want_no_more_lines
        want_result_for_success
      end

      def want_result_for_failure
        expect( exitstatus ).to eql result_for_failure_for_want_stdout_stderr  # :+#hook-out
      end

      def want_result_for_success
        expect( exitstatus ).to be_zero
      end

      def exitstatus
        @exitstatus
      end

      def _fail_with_message_TS & p
        if respond_to? :quickie_fail_with_message_by  # #here2
          quickie_fail_with_message_by( & p )
        else
          _msg = p[]
          fail _msg
        end
      end

      # ~ support & other expectations

      def want_maybe_a_blank_line

        scn = stream_for_want_stdout_stderr

        if scn.unparsed_exists and NEWLINE_ == scn.head_as_is.string
          scn.advance_one
          nil
        end
      end

      def want_a_blank_line

        scn = stream_for_want_stdout_stderr
        _line_o = scn.gets_one
        NEWLINE_ == _line_o.string || fail
      end

      def want_no_more_lines

        scn = stream_for_want_stdout_stderr

        if scn.unparsed_exists
          _em = scn.head_as_is
          _msg = "expected no more lines, had #{ _em.to_a.inspect }"
          _fail_with_message_TS { _msg }
        end
      end

      def count_contiguous_lines_on_stream sym

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        count = 0
        scn = _sout_serr_stream_for_contiguous_lines_on_stream sym
        while scn.gets
          count += 1
        end
        count
      end

      def flush_to_unstyled_string_contiguous_lines_on_stream sym

        _p = CLI_[]::Styling::Unstyle

        _flush_to_string_on_stream_by sym, & _p
      end

      def flush_to_string_contiguous_lines_on_stream sym

        _flush_to_string_on_stream_by sym, & IDENTITY_
      end

      def _flush_to_string_on_stream_by sym

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        s = ::String.new
        scn = _sout_serr_stream_for_contiguous_lines_on_stream sym

        begin
          em = scn.gets
          em or break
          s.concat yield em.string
          redo
        end while nil

        s
      end

      def flush_to_want_stdout_stderr_emission_summary_expecter

        # (it would be nice to use Enumerable.chunk but we have a reduce too)

        scn = stream_for_want_stdout_stderr
        y = []

        sym = nil
        begin

          if scn.no_unparsed_exists
            break
          end

          em = scn.gets_one

          if sym != em.stream_symbol
            a = []
            sym = em.stream_symbol
            y.push Chunk___.new( sym, a )
          end
          a.push em.string
          redo
        end while nil

        EmissionsElement___.new y
      end

      def flush_to_content_scanner
        flush_to_content_scanner_on_stream @__sout_serr_default_stream_symbol__
      end

      def flush_to_content_scanner_on_stream sym

        _st = sout_serr_line_stream_for_contiguous_lines_on_stream sym

        Home_::Want_Line::Scanner.via_line_stream _st
      end

      def sout_serr_line_stream_for_contiguous_lines_on_stream sym

        @__sout_serr_is_baked__ ||= _bake_sout_serr
        _sout_serr_stream_for_contiguous_lines_on_stream( sym ).map_by do | em |
          em.string
        end
      end

      def _sout_serr_stream_for_contiguous_lines_on_stream sym
        _sout_serr_chunk_for do | em |
          sym == em.stream_symbol
        end
      end

      def _sout_serr_chunk_for
        scn = @__sout_serr_actual_scanner__
        p = -> do
          if scn.unparsed_exists and yield( scn.head_as_is )
            scn.gets_one
          else
            p = EMPTY_P_
            nil
          end
        end
        Common_.stream do
          p[]
        end
      end

      # -- set a "nonstandard" (i.e "newschool") test subject

      def stdout_stderr_against_emission em

        _st = Common_::Stream.via_item( em ).flush_to_scanner
        self.stream_for_want_stdout_stderr = _st
        NIL_
      end

      def stdout_stderr_against_emissions em_a

        # the subject of your tests will be this array of emissions.

        _st = Common_::Scanner.via_array em_a
        self.stream_for_want_stdout_stderr = _st
        NIL_
      end

      def stream_for_want_stdout_stderr= x

        @__sout_serr_is_baked__ = true

        @__sout_serr_actual_scanner__ = x
      end

      def stream_for_want_stdout_stderr

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        @__sout_serr_actual_scanner__
      end

      def _bake_sout_serr
        _em_a = flush_baked_emission_array
        @__sout_serr_actual_scanner__ = Scanner_[ _em_a ]
        true
      end

    public

      attr_reader :__sout_serr_default_stream_symbol__

      public(
        :sout_serr_line_stream_for_contiguous_lines_on_stream,
      )
    end

    Frozen_State___ = ::Struct.new :exitstatus, :lines

    Common_ = ::Skylab::Common

    SIMPLE_STYLE_RX__ = CLI_[]::Styling::SIMPLE_STYLE_RX

    class Expectation  # [br], [te]

      class << self

        def via * x_a, & x_p
          via_args x_a, & x_p
        end

        def via_args x_a, & x_p
          new Common_::Scanner.via_array( x_a ), & x_p
        end

        private :new
      end  # >>

      include Home_.lib_.fields::Attributes::Actor::InstanceMethods

      def initialize scn, & p

        @want_is_styled = false
        @method_name = NOTHING_  # #coverpoint3.1
        @stream_symbol = nil

        process_argument_scanner_passively scn

        while scn.unparsed_exists
          __process_the_rest_using_shape_hack scn
        end

        @receive_unstyled_string = p
      end

    private

      def styled=
        @want_is_styled = true
        KEEP_PARSING_
      end

      def __process_the_rest_using_shape_hack scn
        begin
          send scn.head_as_is.class.name, scn
        end
      end

      def Regexp scn
        _same :_curate_content_when_regexp_, scn
      end

      def String scn
        _same :_curate_content_when_string_, scn
      end

      def _same m, scn
        @method_name_for_curate_content = m
        @pattern_x = scn.gets_one
        KEEP_PARSING_
      end

      def Symbol scn
        @stream_symbol = scn.gets_one
        KEEP_PARSING_
      end

    public

      def to_matcher_bound_to test_context
        Matcher___.new self, test_context
      end

      attr_reader(
        :want_is_styled,
        :method_name_for_curate_content,
        :pattern_x,
        :receive_unstyled_string,
        :stream_symbol,
      )
    end

    # -- this is the "newschool" experiment ..

    class Matcher___

      # see [#here.C] oldschool/newschool exegesis

      def initialize exp, tc
        @__mutex = nil
        @_expectation = exp
        @_test_context = tc
      end

      # ~( #open #[#033.3]

      def matches? line_o
        remove_instance_variable :@__mutex  # etc
        @_matchdata = nil ; @_failures = nil
        @_line_object = line_o
        execute
        if @_failures
          ___when_failed
        else
          @_matchdata || ACHIEVED_
        end
      end

      def failure_message  # #copy-paste of [#co.Coverpoint1.1] #coverpoint3.1
        Stream_[ @_failures ].join_into_with_by ::String.new, NEWLINE_ do |p|
          p[]
        end
      end

      # ~)

      def ___when_failed

        if @_test_context.respond_to? :quickie_fail_with_message_by  # #here2
          # (the crux of the hack for this to work in both test fw's)
          _p = method :failure_message  # #[#033.3]
          @_test_context.quickie_fail_with_message_by( & _p )
        else
          UNABLE_
        end
      end

      def execute
        if __cares_about_channel
          if __curate_channel
            _curate_content
          else
            _curate_content  # experimentally, enhance the failure with more detail
          end
        else
          _curate_content
        end
      end

      def _curate_content
        __curate_newlined_ness
        __curate_styled_ness
        m = @_expectation.method_name_for_curate_content
        if m
          send m
        end
      end

      # ~( #testpoint (method names)

      def _curate_content_when_regexp_
        md = @_expectation.pattern_x.match _fully_normal_string
        if md
          @_matchdata = md ; nil
        else
          _add_failure_by do
            "string did not match #{ @_expectation.pattern_x } - #{
              }#{ _fully_normal_string.inspect }"
          end
        end
      end

      def _curate_content_when_string_
        if @_expectation.pattern_x != _fully_normal_string
          _add_failure _fully_normal_string, @_expectation.pattern_x, :string
        end
      end

      # )

      def _fully_normal_string
        send @_fully_normal_string
      end

      def __curate_styled_ness
        if @_expectation.want_is_styled
          s_ = _string_without_newline.gsub SIMPLE_STYLE_RX__, EMPTY_S_
          if s_.length == _string_without_newline.length
            __when_was_not_styled
          end
          @__unstyled_string = s_
          @_fully_normal_string = :__unstyled_string ; nil
        else
          @_fully_normal_string = :_string_without_newline ; nil
        end
      end

      def __when_was_not_styled
        _add_failure_by do
          "expected styled, was not: #{ _string_without_newline.inspect }"
        end
      end

      def __unstyled_string
        @__unstyled_string
      end

      def __curate_newlined_ness
        longer = _actual_line_string
        shorter = longer.chomp
        if shorter.length == longer.length
          _add_failure_by do
            "all lines must be newline terminated (had: #{ _actual_line_string.inspect })"
          end
        end
        @__string_without_newline = shorter ; nil
      end

      def _string_without_newline
        @__string_without_newline
      end

      def _actual_line_string
        @_line_object.string
      end

      def __curate_channel
        if _expected_stream_symbol == _actual_stream_symbol
          ACHIEVED_
        else
          _add_failure _actual_stream_symbol, _expected_stream_symbol, :stream_symbol
        end
      end

      def _actual_stream_symbol
        @_line_object.stream_symbol
      end

      def _expected_stream_symbol
        @_expectation.stream_symbol
      end
      alias_method :__cares_about_channel, :_expected_stream_symbol

      def _add_failure actual_x, expected_x, thing_sym

        _add_failure_by do

          _nf = Common_::Name.via_variegated_symbol thing_sym

          "expected #{ _nf.as_human } #{ expected_x.inspect }, #{
            }had #{ actual_x.inspect }"
        end
      end

      def _add_failure_by & p
        ( @_failures ||= [] ).push p ; nil
      end
    end

    # ~ for "summary"

    class EmissionsElement___

      def initialize a
        @_a = a
        @_st = Common_::Stream.via_nonsparse_array a
      end

      def want_chunk num_x=nil, stream_symbol

        cx = @_st.gets
        if cx
          if stream_symbol == cx.stream_symbol
            if num_x
              d = cx._a.length
              ok = if num_x.respond_to? :include?
                num_x.include? d
              else
                num_x == d
              end
              if ! ok
                fail "expected #{ num_x } `#{ stream_symbol }` lines, had  #{ d }"
              end
            end
          else
            fail "expected `#{ stream_symbol }`, had `#{ cx.stream_symbol }`.."
          end
        else
          fail "expected `#{ stream_symbol }` chunk, had no more chunks"
        end
      end

      def want_no_more_chunks
        cx = @_st.gets
        if cx
          fail "expected no more chunks, had #{ cx.describe }"
        end
      end
    end

    class Chunk___

      attr_reader( :_a, :stream_symbol )

      def initialize sym, a
        @_a = a
        @stream_symbol = sym
      end

      def describe
        "#{ @_a.length } `#{ @stream_symbol }` emission(s)"
      end
    end
  end
end
# #tombstone-A.2: oldschool instance methods module monolith now depdends on matcher
# :+#posterity: we replaced with "methodic" code that was its conceptual ancestor
