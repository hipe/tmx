module Skylab::TestSupport

  class Want_line  # :[#038]

    # assumes @output_s

    class << self

      def [] test_context_class
        test_context_class.include Test_Context_Instance_Methods ; nil
      end

      def shell output_s
        Shell__.new output_s
      end
    end  # >>

    Test_Context_Instance_Methods = ::Module.new

    class Shell__

      include Test_Context_Instance_Methods

      def initialize s
        @output_s = s
      end
    end

    module Test_Context_Instance_Methods

      def excerpt range
        excerpt_lines( range ) * EMPTY_S_
      end

      def excerpt_lines range
        in_string_excerpt_range_of_lines @output_s, range
      end

      def in_string_excerpt_range_of_lines s, range
        beg_d = range.begin
        end_d = range.end
        if beg_d < 0
          if end_d < 0
            excrpt_lines_from_end beg_d, end_d, s
          else
            false
          end
        elsif end_d >= 0
          excrpt_lines_from_beginning beg_d, end_d, s
        else
          false
        end
      end

      def excrpt_lines_from_beginning beg_d, end_d, s

        _RX = Home_.lib_.basic::String.regex_for_line_scanning

        scn = Home_::Library_::StringScanner.new s

        y = []
        current_line_index = 0
        while current_line_index < beg_d
          current_line_index += 1
          if ! scn.skip _RX
            y = false
            break
          end
        end
        if y
          while current_line_index <= end_d
            current_line_index += 1
            s = scn.scan _RX
            if s
              y.push s
            else
              y = false
              break
            end
          end
        end
        y
      end

      def excrpt_lines_from_end beg_d, end_d, s
        if s.length.nonzero?
          scn = backwards_index_stream s, NEWLINE_
          d = s.length - 1
          if NEWLINE_ == s[ -1 ]  # [#sg-020] newline is terminator not separator
            scn.gets
          end
          ( - ( end_d + 1 )).times do
            d = scn.gets
            d or break
          end
        end
        y = nil
        if d
          ( end_d - beg_d + 1 ).times do
            d_ = scn.gets
            if d_
              ( y ||= [] ).push s[ ( d_ + 1 ) .. d ]
              d = d_
            else
              ( y ||= [] ).push s[ 0 .. d ]
              break
            end
          end
        end
        if y
          y.reverse!
        end
        y
      end

      def backwards_index_stream s, sep
        d = s.length - 1
        p = -> do
          r = s.rindex sep, d
          if r
            d = r - 1
            if d < 0
              p = EMPTY_P_
            end
            r
          else
            p = EMPTY_P_ ; r
          end
        end

        Common_::MinimalStream.by do
          p[]
        end
      end

      # ~ using a stateful scanner

      def want_next_nonblank_line_is string
        advance_to_next_nonblank_line
        line.should eql string
      end

      def advance_to_rx rx
        want_line_scanner.advance_to_rx rx
      end

      def advance_to_next_rx rx
        want_line_scanner.advance_to_next_rx rx
      end

      def next_nonblank_line
        advance_to_next_nonblank_line and line
      end

      def next_line
        want_line_scanner.next_line
      end

      def advance_to_next_nonblank_line
        want_line_scanner.advance_to_next_rx NONBLANK_RX__
      end

      def line
        @want_line_scanner.line
      end

      def want_line_scanner
        @want_line_scanner ||= __build_expect_line_scanner
      end

      def __build_expect_line_scanner

        st = line_stream_for_want_line
        if st
          Want_Line_::Scanner.via_stream st
        else
          Want_Line_::Scanner.via_string @output_s
        end
      end

      attr_reader :line_stream_for_want_line
    end

    NONBLANK_RX__ = /[^[:space:]]/
  end

  module Want_Line

    # ==

    # :[#here.1]: the unicode character ("¦") in the "big strings" is NOT
    # part of the expected visualization - it demarcates the beginning and
    # ending of each such line in the test file. we demarcate the lines in
    # this manner because A) the ubiquitous `unindent` won't work for us
    # here because we have significant leading whitespace in some first
    # lines, B) we don't want significant trailing whitespace to be bare in
    # files because it typically generates various annoyances visual and
    # otherwise, and C) this way we can more clearly see where the beginning
    # boundary is without having to write a custom regex each time to
    # de-indent (de-dent?) it. whew!

    class DemarcatedBigString  # < SimpleModel_

      # the idea here is that this *can* be used multiple times but it
      # doesn't expect to be. so it itself is stateless and so reentrant,
      # but we don't cache any of the parsing (and meta-validation) of
      # each line, so this isn't as efficient as it could be for the case
      # of using the same expectation againt multiple cases. but since in
      # practice we rarely do that, we haven't optimized for that.

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize
        @have_the_effect_of_chomping_lines = false
        yield self
        freeze
      end

      attr_writer(
        :demarcator_string,
        :have_the_effect_of_chomping_lines,
      )

      def new big_s
        dup.__init big_s
      end

      private :dup

      def __init big_s
        @big_string = big_s
        freeze
      end

      def want_against_line_stream_under act_st, tc

        _exp_st = __to_expected_line_stream

        Streams_have_same_content[ act_st, _exp_st, tc ]
      end

      def __to_expected_line_stream

        p = nil ; first_p = nil ; subsequent_p = nil
        rx = nil ; scn = nil ; lts_used = nil ; line_via_matchdata = nil

        first_p = -> do
          scn = Home_::Library_::StringScanner.new @big_string
          first_line = scn.scan LINE_RX__

          dem = ::Regexp.escape @demarcator_string

          _find_demarcators_rx = %r(
            \A
            (?<leading_white>[ \t]*)
            #{ dem }
            (?<content_characters>(?:(?!#{ dem }).)*)
            #{ dem }
            $
            (?<lts>#{ LINE_TERMINATION_SEQUENCE_RXS__ })
          )x

          md = _find_demarcators_rx.match first_line
          md or fail __say_didnt_find_demarcators first_line

          lts_used = md[ :lts ]

          rx = %r(
            #{ ::Regexp.escape md[ :leading_white ] }
            #{ dem }
            (?<line_content>.{#{ md[ :content_characters ].length }})
            #{ dem }
            #{ ::Regexp.escape lts_used }
          )x

          scn.pos = 0
          p = subsequent_p
          p[]
        end

        subsequent_p = -> do

          line = scn.scan LINE_RX__
          md = rx.match line
          md or fail __say_didnt_match_derived_pattern( line, rx )

          if scn.eos?
            p = EMPTY_P_
          end

          line_via_matchdata[ md ]
        end

        line_via_matchdata = if @have_the_effect_of_chomping_lines
          -> md do
            md[ :line_content ]
          end
        else
          -> md do
            md[ :line_content ] << lts_used
          end
        end

        p = first_p

        Common_.stream do
          p[]
        end
      end

      def __say_didnt_match_derived_pattern line, _rx
        "demarcators established in the first line #{
          }were not followed by this subsequent line: #{ line.inspect }"
      end

      def __say_didnt_find_demarcators first_line
        "demarcators (#{ @demarcator_string.inspect }) #{
          }not present or incorrectly used in first line - #{ first_line.inspect }"
      end
    end

    # ==

    Want_same_lines = -> do
      convert = -> x do
        if x.respond_to? :gets
          x
        else
          Line_stream_via_string__[ x ]
        end
      end
      -> act_x, exp_x, context do
        Streams_have_same_content[ convert[ act_x ], convert[ exp_x ], context ]
      end
    end.call

    Want_same_string = -> actual_s, expected_s, context do

      p = Home_.lib_.basic::String::LineStream_via_String

      Streams_have_same_content[ p[ actual_s ], p[ expected_s ], context ]
    end

    Want_these_lines_in_array_with_trailing_newlines = -> mixed_upstream, p, context do

      ExpectThese__.call_by do |o|
        o.map_expectations_by do |exp_x|
          if exp_x and ! exp_x.respond_to? :named_captures
            exp_x << NEWLINE_
          end
          exp_x
        end
        o.mixed_upstream = mixed_upstream
        o.receive_yielder = p
        o.test_context = context
      end
    end

    Want_these_lines_in_array = -> mixed_upstream, p, context do

      ExpectThese__.call_by do |o|

        o.mixed_upstream = mixed_upstream
        o.receive_yielder = p
        o.test_context = context
      end
    end

    class ExpectThese__ < Common_::MagneticBySimpleModel

      def initialize
        @map_expectations_by = nil
        super
      end

      def map_expectations_by & p
        @map_expectations_by = p
      end

      attr_writer(
        :mixed_upstream,
        :receive_yielder,
        :test_context,
      )

      def execute

        @_actual_item_scanner = __actual_item_scanner

        _y = __expectation_receiver

        @receive_yielder[ _y ]

        if ! @_actual_item_scanner.no_unparsed_exists
          if @_expectations_terminated_early
            NOTHING_  # hi.
          else
            fail __say_extra
          end
        end
      end

      def __expectation_receiver
        if @map_expectations_by
          y = _expectation_receiver_raw
          map = remove_instance_variable :@map_expectations_by
          ::Enumerator::Yielder.new do |exp_x|
            _use = map[ exp_x ]
            y << _use
          end
        else
          _expectation_receiver_raw
        end
      end

      def _expectation_receiver_raw

        act_scn = @_actual_item_scanner
        @_expectations_terminated_early = false

        ::Enumerator::Yielder.new do |exp_x|

          if act_scn.no_unparsed_exists
            fail __say_missing exp_x

          elsif exp_x
            act_x = act_scn.head_as_is
            if exp_x.respond_to? :named_captures
              if exp_x !~ act_x
                fail _say_not_same exp_x
              end
            elsif exp_x != act_x
              fail _say_not_same exp_x
            end
            act_scn.advance_one
          else
            @_expectations_terminated_early = true ;  # experiment for [tm]
          end
        end
      end

      def __actual_item_scanner
        up_x = remove_instance_variable :@mixed_upstream
        if up_x.respond_to? :gets
          if up_x.respond_to? :flush_to_scanner
            up_x.flush_to_scanner
          else
            No_deps_zerk_[]::Scanner_by.new do
              up_x.gets
            end
          end
        else  # assume array
          Scanner_[ up_x ]
        end
      end

      def _say_not_same exp_x
        Say_not_same__[ _head_as_is, exp_x ]
      end

      def __say_extra
        Say_extra__[ _head_as_is  ]
      end

      def __say_missing exp_x
        Say_missing__[ exp_x ]
      end

      def _head_as_is
        @_actual_item_scanner.head_as_is
      end
    end

    Streams_have_same_content = -> actual_st, expected_st, context do

      begin
        act_s = actual_st.gets
        exp_s = expected_st.gets
        if act_s
          if context.do_debug
            context.debug_IO.puts act_s.inspect
          end
          if exp_s
            if exp_s == act_s
              redo
            else
              fail Say_not_same__[ act_s, exp_s ]
            end
          else
            fail Say_extra__[ act_s ]
          end
        elsif exp_s
          fail Say_missing__[ exp_s ]
        else
          # (when they both end at the same moment, success)
          break
        end
      end while nil
      NIL_
    end

    Say_not_same__ = -> act_s, exp_s do
      "(expected, had): (#{ exp_s.inspect }, #{ act_s.inspect })"
    end

    Say_extra__ = -> s do
      "unexpected extra line - #{ s.inspect }"
    end

    Say_missing__ = -> s do
      "missing expected line - #{ s.inspect }"
    end

    # ==

    class Scanner

      class << self

        def via_line_stream lines
          new lines
        end

        def via_string string
          new Line_stream_via_string__[ string ]
        end

        def via_stream st
          new st
        end

        private :new
      end  # >>

      def initialize up
        @up = up
      end

      attr_reader :line

      # ~ advancing by a counting number of lines from current or end

      def advance_to_before_Nth_last_line d

        skip_until_before_Nth_last_line d
        @line
      end

      def skip_until_before_Nth_last_line d

        buff = Home_.lib_.basic::Rotating_Buffer[ d + 1 ]

        count = -1  # because our buffer runs for one more than the amt requested
        begin
          line = @up.gets
          line or break
          count += 1
          buff << line
          redo
        end while nil

        st = Common_::Stream.via_nonsparse_array buff.to_a

        @line = st.gets
        @up = st

        count
      end

      def buffer_until_line stop_here

        buffer = ""
        s = @line
        begin
          if stop_here == s
            break
          end
          buffer << s
          s = next_line
          s or fail _say_never_found stop_here.inspect
          redo
        end while nil
        buffer
      end

      def advance_N_lines d
        line = nil
        d.times do
          line = @up.gets
        end
        @line = line
        line
      end

      def next_line
        @line = @up.gets
      end

      # ~ convenience macros for paraphernalia

      def want_header sym

        s = want_styled_line
        if s

          exp = "#{ sym }\n"
          if exp == s
            NIL_  # ok - multi-line style, with no trailing colon
          else

            exp_ = "#{ sym }:\n"
            if exp_ == s
              self._WHERE  # still used?
            else
              fail "expecting #{ exp.inspect } or #{ exp_.inspect }"
            end
          end
        end
      end

      def want_styled_line

        @line = @up.gets
        if @line

          line = CLI_[]::Styling.unstyle_styled @line

          if line
            @line = line
            line
          else
            fail "not styled: #{ line.inspect }"
          end
        else
          fail "expected line, had none"
        end
      end

      # ~ advancing by searching for a regexp (positively or negatively)

      def << expected_s

        @line = @up.gets
        if @line
          if expected_s == @line
            self
          else
            fail "expected #{ expected_s.inspect }, had #{ @line.inspect }"
          end
        else
          fail "expected #{ expected_s.inspect }, had no more lines"
        end
      end

      def want_nonblank_line

        @line = @up.gets
        BLANK_RX___ =~ @line and fail "expected nonblank, had #{ @line.inspect }"
        NIL_
      end

      def blank_line_then rx

        _ok = exactly_one_blank_line

        _ok && want_that_line_matches( rx )
      end

      def exactly_one_blank_line

        d = skip_blank_lines
        if 1 == d
          ACHIEVED_  # not sure
        else
          fail ___say_not_one( d, "blank line" )
        end
      end

      def ___say_not_one d, s

        "needed one #{ s }, had #{ d } (#{ at_where 'near ' })"
      end

      def want_blank_line

        @line = @up.gets
        BLANK_RX___ =~ @line or fail ___say_current_line_not_blank
        NIL_
      end

      def __say_current_line_not_blank
        "not blank: #{ @line.inspect }"
      end

      def skip_blank_lines

        @line = @up.gets
        _count_from_advance_to_not_rx BLANK_RX___
      end

      BLANK_RX___ = /\A[[:space:]]*\z/

      def advance_past_lines_that_match rx

        @line = @up.gets
        advance_to_not_rx rx
      end

      def advance_to_next_rx rx

        @line = @up.gets
        advance_to_rx rx
      end

      def advance_to_not_rx rx

        _count_from_advance_to_not_rx rx
        @line
      end

      def skip_lines_that_match rx

        @line = @up.gets
        _count_from_advance_to_not_rx rx
      end

      def _count_from_advance_to_not_rx rx

        count = 0
        begin
          @line or fail "never found a line that didn't match #{ rx.inspect }"
          if rx =~ @line
            count += 1
            @line = @up.gets
            redo
          end
          break
        end while nil
        count
      end

      def advance_to_rx rx

        begin
          @line or fail _say_never_found rx
          md = rx.match @line
          md and break
          @line = @up.gets
          redo
        end while nil
        md
      end

      def _say_never_found desc_s
        "never found before end of file: #{ desc_s }"
      end

      def want_that_next_line_matches rx
        @line = @up.gets
        want_that_line_matches rx
      end

      def want_that_line_matches rx

        if rx.respond_to? :ascii_only?
          if rx == @line
            ACHIEVED_
          else
            fail _say_current_line_does_not_match rx
          end
        elsif rx =~ @line
          ACHIEVED_
        else
          fail _say_current_line_does_not_match rx
        end
      end

      def _say_current_line_does_not_match rx

        _ = if rx.respond_to? :ascii_only?
          rx.inspect
        else
          "/#{ rx.source }/"
        end
        "did not match #{ _ }#{ at_where }"
      end

      def advance_until_line_that_equals s

        count = 0
        begin
          @line = @up.gets
          if ! @line
            fail ___say_never_found_line s
          end
          count += 1
          if s == @line
            break
          end
          redo
        end while nil
        count
      end

      def ___say_never_found_line s
        "never found line before end of stream - #{ s.inspect }"
      end

      # ~ finish

      def finish
        count = 0
        begin
          if @up.gets
            count += 1
            redo
          end
          break
        end while nil
        count
      end

      def flush
        s = ""
        begin
          line = @up.gets
          line or break
          s.concat line
          redo
        end while nil
        s
      end

      def want_no_more_lines
        @line = @up.gets
        if @line
          fail "expected no more lines#{ at_where ', had ' }"
        end
      end

      def at_where s=" - "

        line = @line
        if line
          "#{ s }#{ line.inspect }"
        else
          if /\A[ ,]/ =~ s
            _space = SPACE_
          end
          "#{ _space }at end of file"
        end
      end

      # ~ building fake files

      def build_fake_file_from_line_and_every_line_while_rx rx
        fake_lines = []
        begin
          fake_lines.push @line
          @line = @up.gets
          if @line && rx =~ @line
            redo
          end
        end while nil

        Fake_File__.new fake_lines
      end

      class Fake_File__

        def initialize a
          @a = a
        end

        def fake_open
          Common_::Stream.via_nonsparse_array @a
        end
      end

      def gets  # so it can act like a minimal stream
        @up.gets
      end
    end

    class File_Shell

      class << self
        alias_method :[], :new
      end

      def initialize path
        @path = path
        @content = ::File.read path
      end

      def contains str
        @content.include? str
      end
    end

    # ==

    Line_stream_via_string__ = -> s do
      Home_.lib_.basic::String::LineStream_via_String[ s ]
    end

    Scanner_ = -> a do  # this is certain to move up
      Common_::Scanner.via_array a
    end

    # ==

    Want_line::Want_Line_ = self
    LINE_TERMINATION_SEQUENCE_RXS__ = '(?:\n|\r\n?|\z)'
    LINE_RX__ = /[^\r\n]*#{ LINE_TERMINATION_SEQUENCE_RXS__ }/

    # ==
  end
end
