module Skylab::TestSupport

  module Expect_Stdout_Stderr  # see [#029] the expect omnibus and narrative #intro-to-gamma

    # assumes {  @IO_spy_group_for_expect_stdout_stderr | your own `build_baked_em_a` }

    # NOTE currently this mutates emission strings!

    module InstanceMethods
    private

      # ~ before the expectation, set default behavior

      def on_stream stream_symbol
        @__sout_serr_default_stream_symbol__ = stream_symbol ; nil
      end

      # ~ simple expect "macros"

      def expect_header_line s
        expect :styled, "#{ s }:"
      end

      # ~ expect

      def expect * x_a, & p

        @__sout_serr_expectation__ = bld_sout_serr_expectation_via_iambic x_a, & p

        __sout_serr_actual_stream_is_resolved__.nil? and rslv_sout_serr_actual_stream

        __send__ @__sout_serr_expectation__.method_name
      end

      def bld_sout_serr_expectation_via_iambic x_a, & p
        _sout_serr_expectation_class.new(
          Callback_::Iambic_Stream.via_array( x_a ),
            & p )
      end

      def _sout_serr_expectation_class
        Expectation__
      end

      def rslv_sout_serr_actual_stream
        @__sout_serr_actual_stream_is_resolved__ = true
        @__sout_serr_actual_stream__ = Callback_::Iambic_Stream.via_array(
          build_baked_em_a )
        nil
      end

      def build_baked_em_a  # :+#hook-near #universal
        @IO_spy_group_for_expect_stdout_stderr.release_lines
      end

      # ~ other expectations

      def expect_maybe_a_blank_line

        __sout_serr_actual_stream_is_resolved__.nil? and rslv_sout_serr_actual_stream

        st = @__sout_serr_actual_stream__
        if st.unparsed_exists and NEWLINE_ == st.current_token.string
          st.advance_one
          nil
        end
      end

      def expect_no_more_lines

        __sout_serr_actual_stream_is_resolved__.nil? and rslv_sout_serr_actual_stream

        if @__sout_serr_actual_stream__.unparsed_exists
          _x = @__sout_serr_actual_stream__.current_token
          fail "expected no more lines, had #{ _x.to_a.inspect }"
        end
      end

      def count_contiguous_lines_on_stream sym
        count = 0
        st = _sout_serr_stream_for_contiguous_lines_on_stream sym
        while st.gets
          count += 1
        end
        count
      end

      def get_string_for_contiguous_lines_on_stream sym
        io = TestSupport_::Library_::StringIO.new
        st = _sout_serr_stream_for_contiguous_lines_on_stream sym
        em = st.gets
        while em
          io.write em.string
          em = st.gets
        end
        io.string
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
            _sout_serr_receive_chomped_emission_line s
          else
            fail "for now expecting all lines to be newine terminated: #{ line.inspect }"
          end
        end
      end

      def _sout_serr_receive_chomped_emission_line line
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
    public

      attr_reader :__sout_serr_actual_stream_is_resolved__

      attr_reader :__sout_serr_default_stream_symbol__
    end

    Callback_ = ::Skylab::Callback

    SIMPLE_STYLE_RX__ = /\e  \[  \d+  (?: ; \d+ )*  m  /x  # copy-paste [hl]

    METHODIC_ = Callback_::Actor.methodic_lib

    class Expectation__

      include METHODIC_.iambic_processing_instance_methods

      def initialize st, & p
        @expect_is_styled = false
        @method_name = :_sout_serr_expect_and_resolve_emission
        process_iambic_stream_passively st
        while st.unparsed_exists
          process_the_rest_using_shape_hack st
        end
        p and self._DO_ME_receive_proc p
      end

      attr_reader :stream_symbol, :expect_is_styled,
        :method_name, :pattern_x

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

      METHODIC_.cache_iambic_writer_methods self
    end
  end
end
# :+#posterity: we replaced with "methodic" code that was its conceptual ancestor
