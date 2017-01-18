module Skylab::TestSupport

  module Expect_Stdout_Stderr  # lots of "theory" in [#029]

    # NOTE this mutates strings under "oldchool" techniques! (see [#]scope )
    # assumes {  @IO_spy_group_for_expect_stdout_stderr | your own `flush_baked_emission_array` }

    module Test_Context_Instance_Methods

      # -- freeze an invocation as a shared state [#.A]

      def flush_invocation_to_help_screen_oriented_state  # current favorite

        _state = flush_frozen_state_from_expect_stdout_stderr

        help_screen_oriented_state_via_invocation_state _state
      end

      def help_screen_oriented_state_via_invocation_state state  # [y2]

        _cls = _expect_section::Help_Screen_State

        _cls.via :state, state, :stream, :e
      end

      def flush_invocation_to_help_screen_tree

        _state = flush_frozen_state_from_expect_stdout_stderr

        _expect_section.tree_via :state, _state, :stream, :e
      end

      define_method :_expect_section, ( Lazy_.call do
        Home_.lib_.zerk.test_support::CLI::Expect_Section_Fail_Early
      end )

      def flush_frozen_state_from_expect_stdout_stderr

        remove_instance_variable :@invocation

        Frozen_State___.new(
          remove_instance_variable( :@exitstatus ),
          release_lines_for_expect_stdout_stderr,
        ).freeze
      end

      def flush_baked_emission_array  # :+#hook-near #universal
        release_lines_for_expect_stdout_stderr
      end

      def release_lines_for_expect_stdout_stderr
        _ = remove_instance_variable :@IO_spy_group_for_expect_stdout_stderr
        _.release_lines
      end

      # -- optional support for "full stack" CLI testing

      def using_expect_stdout_stderr_invoke_via_argv a  # might mutate arg

        using_expect_stdout_stderr_invoke_via(
          :mutable_argv, a,
          :prefix, argv_prefix_for_expect_stdout_stderr,
        )
      end

      def argv_prefix_for_expect_stdout_stderr  # #hook-in:1
        NIL_
      end

      def using_expect_stdout_stderr_invoke_with_no_prefix * argv

        using_expect_stdout_stderr_invoke_via(
          :mutable_argv, argv,
          :prefix, nil,
        )
      end

      def using_expect_stdout_stderr_invoke_via * x_a
        using_expect_stdout_stderr_invoke_via_iambic x_a
      end

      def using_expect_stdout_stderr_invoke_via_iambic x_a

        opt = Options___.new
        x_a.each_slice 2 do | k, x |
          opt[ k ] = x
        end
        mutable_argv, prefix = opt.to_a

        if prefix
          mutable_argv[ 0, 0 ] = prefix
        end

        init_invocation_for_expect_stdout_stderr mutable_argv

        path = working_directory_for_expect_stdout_stderr
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

      def working_directory_for_expect_stdout_stderr
        NOTHING_
      end

      Options___ = ::Struct.new :mutable_argv, :prefix

      def init_invocation_for_expect_stdout_stderr argv

        g = __build_IO_spy_group_for_expect_stdout_stderr
        @IO_spy_group_for_expect_stdout_stderr = g

        _s_a = invocation_strings_for_expect_stdout_stderr  # #hook-out:1

        _x = self.CLI_options_for_expect_stdout_stderr

        invo = build_invocation_for_expect_stdout_stderr(
          argv, * g.values_at( :i, :o, :e ), _s_a, * _x )

        if instance_variable_defined? :@for_expect_stdout_stderr_prepare_invocation
          @for_expect_stdout_stderr_prepare_invocation[ invo ]
        else
          for_expect_stdout_stderr_prepare_invocation invo
        end

        @invocation = invo

        NIL
      end

      def build_invocation_for_expect_stdout_stderr argv, sin, sout, serr, pn_s_a, * xtra

        subject_CLI.new( argv, sin, sout, serr, pn_s_a, * xtra )  # #hook-out
      end

      def __build_IO_spy_group_for_expect_stdout_stderr

        g = Home_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug  # :+#hook-out
        end

        g.debug_IO = debug_IO  # :+#hook-out

        g.add_stream :i, ( stdin_for_expect_stdout_stderr || :__instream_not_used_yet__ )

        g.add_stream :o

        io = stderr_for_expect_stdout_stderr
        if io
          g.add_stream :e, io
        else
          g.add_stream :e
        end
        g
      end

      attr_accessor :IO_spy_group_for_expect_stdout_stderr, :invocation  # for hax

      alias_method :init_invocation_for_expect_stdout_stderr_,
        :init_invocation_for_expect_stdout_stderr  # for hax

      attr_reader :stdin_for_expect_stdout_stderr,  # :+#hook-in
        :stderr_for_expect_stdout_stderr

      def CLI_options_for_expect_stdout_stderr
        NIL_
      end

    private

      def for_expect_stdout_stderr_prepare_invocation _  # :+#hook-in
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

      def expect_header_line s
        expect :styled, s  # no expectation of colons here, because [#072]
      end

      # ~ expect

      def expect * x_a, & p

        expect_stdout_stderr_via_arglist x_a, & p
      end

      def expect_stdout_stderr_via_arglist x_a, & p

        expect_stdout_stderr_via Expectation.via_args( x_a, & p )
      end

      def expect_stdout_stderr_via exp

        @__sout_serr_expectation__ = exp

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        p = exp.receive_unstyled_string

        ok = __send__ exp.method_name

        if ok && p
          s =  @__sout_serr_line__
          if ! s
            s = @__sout_serr_emission__.string.gsub SIMPLE_STYLE_RX__, EMPTY_S_
            s.chomp!
          end
          ok = p[ s ]
        end
        ok
      end

      # ~ for the end

      def expect_failed
        expect_no_more_lines
        expect_result_for_failure
      end

      def expect_succeeded
        expect_no_more_lines
        expect_result_for_success
      end

      def expect_result_for_failure
        exitstatus.should eql result_for_failure_for_expect_stdout_stderr  # :+#hook-out
      end

      def expect_result_for_success
        exitstatus.should be_zero
      end

      def exitstatus
        @exitstatus
      end

      # ~ support & other expectations

      def expect_maybe_a_blank_line

        st = stream_for_expect_stdout_stderr

        if st.unparsed_exists and NEWLINE_ == st.head_as_is.string
          st.advance_one
          nil
        end
      end

      def expect_a_blank_line

        st = stream_for_expect_stdout_stderr
        _x = st.gets_one
        _x.string.should eql NEWLINE_
      end

      def expect_no_more_lines

        st = stream_for_expect_stdout_stderr

        if st.unparsed_exists
          _x = st.head_as_is
          fail "expected no more lines, had #{ _x.to_a.inspect }"
        end
      end

      def count_contiguous_lines_on_stream sym

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        count = 0
        st = _sout_serr_stream_for_contiguous_lines_on_stream sym
        while st.gets
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

        s = ""
        st = _sout_serr_stream_for_contiguous_lines_on_stream sym

        begin
          em = st.gets
          em or break
          s.concat yield em.string
          redo
        end while nil

        s
      end

      def flush_to_expect_stdout_stderr_emission_summary_expecter

        # (it would be nice to use Enumerable.chunk but we have a reduce too)

        st = stream_for_expect_stdout_stderr
        y = []

        sym = nil
        begin

          if st.no_unparsed_exists
            break
          end

          em = st.gets_one

          if sym != em.stream_symbol
            a = []
            sym = em.stream_symbol
            y.push Chunk___.new( sym, a )
          end
          a.push em.string
          redo
        end while nil

        Emissions_Element___.new y
      end

      def flush_to_content_scanner
        flush_to_content_scanner_on_stream @__sout_serr_default_stream_symbol__
      end

      def flush_to_content_scanner_on_stream sym

        _st = sout_serr_line_stream_for_contiguous_lines_on_stream sym

        Home_::Expect_Line::Scanner.via_line_stream _st
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
        st = @__sout_serr_actual_stream__
        p = -> do
          if st.unparsed_exists and yield( st.head_as_is )
            st.gets_one
          else
            p = EMPTY_P_
            nil
          end
        end
        Common_.stream do
          p[]
        end
      end

      # ~ support for the oldschool way

      def sout_serr_expect_given_regex  # [te]
        if _sout_serr_expect_and_resolve_emission_line
          @__sout_serr_line__.should match @__sout_serr_expectation__.pattern_x
          @__sout_serr_emission__
        end
      end

      def sout_serr_expect_given_string  # [te]
        if _sout_serr_expect_and_resolve_emission_line
          @__sout_serr_line__.should eql @__sout_serr_expectation__.pattern_x
          @__sout_serr_emission__
        end
      end

      def _sout_serr_expect_and_resolve_emission_line
        if _sout_serr_expect_and_resolve_emission
          line = @__sout_serr_emission__.string
          s = line.chomp!  # NOTE - we mutate it for now!
          if s
            __sout_serr_receive_chomped_emission_line s
          else
            fail ___say_not_newlined line
          end
        end
      end

      def ___say_not_newlined line
        "for now expecting all lines to be newline terminated: #{ line.inspect }"
      end

      def __sout_serr_receive_chomped_emission_line line
        if @__sout_serr_expectation__.expect_is_styled
          s = line.dup.gsub! SIMPLE_STYLE_RX__, EMPTY_S_
          if s
            @__sout_serr_line__ = s
            ACHIEVED_
          else
            fail "expected styled, was not: #{ line.inspect }"
          end
        else
          @__sout_serr_line__ = line
          ACHIEVED_
        end
      end

      def _sout_serr_expect_and_resolve_emission
        exp = @__sout_serr_expectation__
        st = @__sout_serr_actual_stream__
        if st.unparsed_exists
          em = st.gets_one
          @__sout_serr_emission__ = em
          @__sout_serr_line__ = nil
          stream_sym = exp.stream_symbol
          stream_sym ||= __sout_serr_default_stream_symbol__
          if stream_sym
            if stream_sym == em.stream_symbol
              ACHIEVED_
            else
              fail "expected emission on channel '#{ stream_sym }', #{
                }but emission was on channel '#{ em.stream_symbol }'"
            end
          else
            ACHIEVED_
          end
        else
          fail "expected an emission, had none"
        end
      end

      # -- set a "nonstandard" (i.e "newschool") test subject

      def stdout_stderr_against_emission em

        _st = Common_::Stream.via_item( em ).flush_to_scanner
        self.stream_for_expect_stdout_stderr = _st
        NIL_
      end

      def stdout_stderr_against_emissions em_a

        # the subject of your tests will be this array of emissions.

        _st = Common_::Scanner.via_array em_a
        self.stream_for_expect_stdout_stderr = _st
        NIL_
      end

      def stream_for_expect_stdout_stderr= x

        @__sout_serr_is_baked__ = true

        @__sout_serr_actual_stream__ = x
      end

      def stream_for_expect_stdout_stderr

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        @__sout_serr_actual_stream__
      end

      def _bake_sout_serr
        @__sout_serr_actual_stream__ = Common_::Scanner.via_array(
          flush_baked_emission_array )

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

      include Home_.lib_.fields::Attributes::Lib::Polymorphic_Processing_Instance_Methods

      def initialize st, & p

        @expect_is_styled = false
        @method_name = :_sout_serr_expect_and_resolve_emission
        @stream_symbol = nil

        process_argument_scanner_passively st

        while st.unparsed_exists
          __process_the_rest_using_shape_hack st
        end

        @receive_unstyled_string = p
      end

    private

      def styled=
        @expect_is_styled = true
        KEEP_PARSING_
      end

      def __process_the_rest_using_shape_hack st
        begin
          send st.head_as_is.class.name, st
        end
      end

      def Regexp st
        @method_name = :sout_serr_expect_given_regex
        @pattern_x = st.gets_one
        KEEP_PARSING_
      end

      def String st
        @method_name = :sout_serr_expect_given_string
        @pattern_x = st.gets_one
        KEEP_PARSING_
      end

      def Symbol st
        @stream_symbol = st.gets_one
        KEEP_PARSING_
      end

    public

      def to_matcher_bound_to test_context
        Matcher___.new self, test_context
      end

      attr_reader(
        :expect_is_styled,
        :method_name,
        :pattern_x,
        :receive_unstyled_string,
        :stream_symbol,
      )
    end

    # -- this is the "newschool" experiment ..

    class Matcher___

      # most of this is necessarily redundant (in spirit) with the above.
      # see [#]oldschool-newschool-exegesis

      def initialize exp, tc
        @_expectation = exp
        @_test_context = tc
      end

      def matches? line_o

        exp = @_expectation
        @_matchdata = nil

        @_failures = nil
        sym = exp.stream_symbol
        if sym
          if sym != line_o.stream_symbol
            _add_failure line_o.stream_symbol, sym, :stream_symbol
          end
        end

        m = exp.method_name
        if m
          @_against_string = if exp.expect_is_styled
            __unstyle line_o.string
          else
            __chomp line_o.string
          end

          send m
        elsif exp.expect_is_styled
          self._ETC
        end

        if @_failures
          ___when_failed
        else
          @_matchdata || :_expect_stdout_stderr_matched_
        end
      end

      def ___when_failed

        if @_test_context.respond_to? :quickie_fail_with_message_by
          # (the crux of the hack for this to work in both test fw's)
          _p = method :failure_message_for_should
          @_test_context.quickie_fail_with_message_by( & _p )
        else
          UNABLE_
        end
      end

      def __unstyle s
        s_ = s.dup.gsub! SIMPLE_STYLE_RX__, EMPTY_S_
        if s_
          _yes = s_.chomp!
          if ! _yes
            _say_no_newline s_
          end
          s_
        else
          _add_failure_by do
            "expected styled, was not: #{ s.inspect }"
          end
          s
        end
      end

      def __chomp s
        s_ = s.chomp
        if s_.length == s.length
          _say_no_newline s
        end
        s_
      end

      def _say_no_newline s

        _add_failure_by do
          "all lines must be newline terminated (had: #{ s.inspect })"
        end
        NIL_
      end

      def sout_serr_expect_given_regex

        md = @_expectation.pattern_x.match @_against_string
        if md
          @_matchdata = md
        else
          _add_failure_by do
            "string did not match #{ @_expectation.pattern_x } - #{
              }#{ @_against_string.inspect }"
          end
        end
        NIL_
      end

      def sout_serr_expect_given_string

        if @_expectation.pattern_x != @_against_string
          _add_failure @_against_string, @_expectation.pattern_x, :string
        end
        NIL_
      end

      def _add_failure * trio

        actual_x, expected_x, thing_sym = trio

        _add_failure_by do

          _nf = Common_::Name.via_variegated_symbol thing_sym

          "expected #{ _nf.as_human } #{ expected_x.inspect }, #{
            }had #{ actual_x.inspect }"
        end
      end

      def _add_failure_by & p

        ( @_failures ||= [] ).push p
        NIL_
      end

      def failure_message_for_should

        _s_a = @_failures.reduce [] do | m, p |
          m << p[]
        end

        _s_a.join NEWLINE_
      end
    end

    # ~ for "summary"

    class Emissions_Element___

      def initialize a
        @_a = a
        @_st = Common_::Stream.via_nonsparse_array a
      end

      def expect_chunk num_x=nil, stream_symbol

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

      def expect_no_more_chunks
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
# :+#posterity: we replaced with "methodic" code that was its conceptual ancestor
