module Skylab::TestSupport

  module Expect_Stdout_Stderr  # see [#029] the expect omnibus and narrative #intro-to-gamma

    # assumes {  @IO_spy_group_for_expect_stdout_stderr | your own `flush_baked_emission_array` }

    # NOTE currently this mutates emission strings!

    module Test_Context_Instance_Methods

      # ~ begin optional support for "full stack" CLI (assuming conventions)

      def using_expect_stdout_stderr_invoke_via_argv a  # might mutate arg

        _init_invocation_and_invoke_against_mutable_argv_and_prefix(
          a, argv_prefix_for_expect_stdout_stderr )
      end

      def argv_prefix_for_expect_stdout_stderr  # :+#hook-in
        NIL_
      end

      def using_expect_stdout_stderr_invoke_with_no_prefix * argv

        _init_invocation_and_invoke_against_mutable_argv_and_prefix argv, nil
      end

      def _init_invocation_and_invoke_against_mutable_argv_and_prefix a, a_

        init_invocation_for_expect_stdout_stderr

        if a_
          a[ 0, 0 ] = a_
        end

        @exitstatus = @invocation.invoke a

        NIL_
      end

      def init_invocation_for_expect_stdout_stderr

        g = Home_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug  # :+#hook-out
        end

        g.debug_IO = debug_IO  # :+#hook-out

        io = stdin_for_expect_stdout_stderr
        if io
          g.add_stream :i, io
        else
          g.add_stream :i, :__instream_not_used_yet__
        end

        g.add_stream :o

        io = stderr_for_expect_stdout_stderr
        if io
          g.add_stream :e, io
        else
          g.add_stream :e
        end

        @IO_spy_group_for_expect_stdout_stderr = g

        invo = subject_CLI.new(  # :+#hook-out
          * g.values_at( :i, :o, :e ),
          invocation_strings_for_expect_stdout_stderr,  # :+#hook-out
          * self.CLI_options_for_expect_stdout_stderr,
        )

        if instance_variable_defined? :@for_expect_stdout_stderr_prepare_invocation
          @for_expect_stdout_stderr_prepare_invocation[ invo ]
        else
          for_expect_stdout_stderr_prepare_invocation invo
        end

        @invocation = invo

        NIL_
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

      # ~ end

      # ~ before the expectation, set default behavior

      def on_stream stream_symbol
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

        @__sout_serr_expectation__ = bld_sout_serr_expectation_via_iambic x_a, & p

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        exp = @__sout_serr_expectation__
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

      def bld_sout_serr_expectation_via_iambic x_a, & p
        _sout_serr_expectation_class.new(
          Callback_::Polymorphic_Stream.via_array( x_a ),
            & p )
      end

      def _sout_serr_expectation_class
        Expectation__
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
        @exitstatus.should eql result_for_failure_for_expect_stdout_stderr  # :+#hook-out
      end

      def expect_result_for_success
        @exitstatus.should be_zero
      end

      # ~ support & other expectations

      def expect_maybe_a_blank_line

        st = stream_for_expect_stdout_stderr

        if st.unparsed_exists and NEWLINE_ == st.current_token.string
          st.advance_one
          nil
        end
      end

      def expect_no_more_lines

        st = stream_for_expect_stdout_stderr

        if st.unparsed_exists
          _x = st.current_token
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

        _p = Home_.lib_.brazen::CLI::Styling::Unstyle

        _flush_to_string_on_stream_by sym, & _p
      end

      def flush_to_string_contiguous_lines_on_stream sym

        _flush_to_string_on_stream_by sym, & IDENTITY_
      end

      def _flush_to_string_on_stream_by sym

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        io = Home_::Library_::StringIO.new
        st = _sout_serr_stream_for_contiguous_lines_on_stream sym

        begin
          em = st.gets
          em or break
          io.write yield em.string
          redo
        end while nil

        io.string
      end

      def flush_to_expect_stdout_stderr_emission_summary_expecter

        # (it would be nice to use Enumerable.chunk by we have a reduce too)

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

        _st = sout_serr_line_stream_for_contiguous_lines_on_stream(
          @__sout_serr_default_stream_symbol__ )

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
          if st.unparsed_exists and yield( st.current_token )
            st.gets_one
          else
            p = EMPTY_P_
            nil
          end
        end
        Callback_.stream do
          p[]
        end
      end

      # ~~ implementation support

      def _sout_serr_expect_given_regex
        if _sout_serr_expect_and_resolve_emission_line
          @__sout_serr_line__.should match @__sout_serr_expectation__.pattern_x
          @__sout_serr_emission__
        end
      end

      def _sout_serr_expect_given_string
        if _sout_serr_expect_and_resolve_emission_line
          @__sout_serr_line__.should eql @__sout_serr_expectation__.pattern_x
          @__sout_serr_emission__
        end
      end

      def _sout_serr_expect_and_resolve_emission_line
        if _sout_serr_expect_and_resolve_emission
          line = @__sout_serr_emission__.string  # WE MUTATE IT for now
          s = line.chomp!
          if s
            __sout_serr_receive_chomped_emission_line s
          else
            fail "for now expecting all lines to be newine terminated: #{ line.inspect }"
          end
        end
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

      def stream_for_expect_stdout_stderr

        @__sout_serr_is_baked__ ||= _bake_sout_serr

        @__sout_serr_actual_stream__
      end

      def _bake_sout_serr
        @__sout_serr_actual_stream__ = Callback_::Polymorphic_Stream.via_array(
          flush_baked_emission_array )

        true
      end

      def flush_frozen_frame_from_expect_stdout_stderr  # for [#.A] frame tech.

        gr = remove_instance_variable :@IO_spy_group_for_expect_stdout_stderr
        gr.freeze

        fr = Frozen_Frame___.new(
          remove_instance_variable( :@exitstatus ),
          gr )
        fr.freeze
      end

      def flush_baked_emission_array  # :+#hook-near #universal

        sg = remove_instance_variable :@IO_spy_group_for_expect_stdout_stderr
        sg.release_lines
      end
    public


      attr_reader :__sout_serr_default_stream_symbol__
    end

    Frozen_Frame___ = ::Struct.new :exitstatus, :IO_spy_group

    Callback_ = ::Skylab::Callback

    SIMPLE_STYLE_RX__ = Home_.lib_.brazen::CLI::Styling::SIMPLE_STYLE_RX

    METHODIC_ = Callback_::Actor::Methodic

    class Expectation__

      include METHODIC_.polymorphic_processing_instance_methods

      def initialize st, & p
        @expect_is_styled = false
        @method_name = :_sout_serr_expect_and_resolve_emission
        process_polymorphic_stream_passively st
        while st.unparsed_exists
          process_the_rest_using_shape_hack st
        end
        @receive_unstyled_string = p
      end

      attr_reader :stream_symbol, :expect_is_styled,
        :method_name, :pattern_x, :receive_unstyled_string

    private

      def styled=
        @expect_is_styled = true
        KEEP_PARSING_
      end

      def process_the_rest_using_shape_hack st
        begin
          send st.current_token.class.name.intern, st
        end
      end

      def Regexp st
        @method_name = :_sout_serr_expect_given_regex
        @pattern_x = st.gets_one
        KEEP_PARSING_
      end

      def String st
        @method_name = :_sout_serr_expect_given_string
        @pattern_x = st.gets_one
        KEEP_PARSING_
      end

      def Symbol st
        @stream_symbol = st.gets_one
        KEEP_PARSING_
      end

      METHODIC_.cache_polymorphic_writer_methods self
    end

    # ~ for "summary"

    class Emissions_Element___

      def initialize a
        @_a = a
        @_st = Callback_::Stream.via_nonsparse_array a
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
