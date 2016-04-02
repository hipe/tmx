module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI::Help_Screens

    # [#br-045] / #[#br-106] blind rewrite!

    def self.[] tcc
      Non_Interactive_CLI[ tcc ]
      tcc.send :define_singleton_method, :given_screen, Given_screen___
      tcc.include self
    end

    # -

      Given_screen___ = -> & p do

        given( & p )

        yes = true ; x = nil
        define_method :_hsz_screen do
          if yes
            yes = false
            x = __build_hsz_screen
          end
          x
        end
      end

    # -

      # -- methods that produce subjects

      def section sym
        _hsz_screen.section sym
      end

      def __build_hsz_screen
        Coarse_Parse.new niCLI_state.lines
      end

      # -- methods that produce predicates (matchers)

      def have_first_usage_line_of s
        First_usage_line___[].for s, self
      end

      First_usage_line___ = Lazy_.call do
        o = Regex_Based_Matcher__.new %r(\Ausage: xyzi ([^<]+) <action> \[named args\]$)
        o.line_offset = 0
        o.styled
        o.subject_noun_phrase = "first usage line"
        o
      end

      def have_second_usage_line_of s
        Second_usage_line___[].for s, self
      end

      Second_usage_line___ = Lazy_.call do
        o = Regex_Based_Matcher__.new %r(\A[ ]{2,}xyzi ([^-]+) -h <action>$)
        o.line_offset = 1
        o.styled
        o.subject_noun_phrase = "second usage line"
        o
      end

      def be_description_line_of opt_sym=nil, exp_s
        o = Single_description_line___[].for exp_s, self
        if opt_sym
          o.send opt_sym  # :#here, nasty
        end
        o
      end

      Single_description_line___ = Lazy_.call do
        o = Regex_Based_Matcher__.new %r(\Adescription: (.+)$)
        o.line_offset = 0
        o.subject_noun_phrase = "single description line"
        o
      end

      def have_item_pair_of opt_sym=nil, a, b
        Item_Pair_Matcher___.new opt_sym, a, b, self
      end

      def be_invite_line_of s
        Invite_line___[].for s, self
      end

      Invite_line___ = Lazy_.call do

        o = Regex_Based_Matcher__.new(
          %r(\Ause 'xyzi ([^-]+) -h <action>' for help on that action\.$) )

        o.line_offset = 0
        o.styled
        o.subject_noun_phrase = "invite line"
        o
      end

      # --

    # ==

    class Coarse_Parse

      def initialize lines
        @_h = Coarse_pass__[ lines ]
        @_section_cache = {}
      end

      def section sym
        @_section_cache.fetch sym do
          _a = @_h.fetch sym
          x = Section___.new _a
          @_section_cache[ sym ] = x
          x
        end
      end
    end

    class Section___

      def initialize a
        @_a = a
      end

      def must_have_styled_line_matching rx

        found_non_styled = nil
        whine = true

        st = to_line_stream
        begin
          li = st.gets
          li or break
          if li.is_styled
            if rx =~ li._unstyled_string
              whine = false
              break
            end
            redo
          end
          if rx =~ li.string
            ( found_non_styled ||= [] ).push li
          end
          redo
        end while nil

        if whine
          if found_non_styled
            raise __say_was_not_styled found_non_styled
          else
            raise __say_no_line_matching rx
          end
        end
      end

      def __say_was_not_styled a
        if 1 == a.length
          "was not styled - #{ a[ 0 ].string.inspect }"
        else
          "#{ a.length } lines matched but were not styled"
        end
      end

      def __say_no_line_matching rx
        "no lined matched /#{ rx.source }/ (of #{ @_a.length } line(s))"
      end

      def first_line
        line_at_offset 0
      end

      def line_at_offset d
        st = to_line_stream
        d_ = 0
        begin
          li = st.gets
          li or break
          if d == d_
            x = li
            break
          end
          d_ += 1
          redo
        end while nil
        if x
          x
        else
          fail ___say_etc d
        end
      end

      def ___say_etc d
        "no line at offset #{ d }. have #{ @_line_cache.length } lines."
      end

      def to_line_stream

        # internally we work with "vendor lines" that come from [#ts-029],
        # for whom being concerned with line styling is above its scope.
        # as such we "upgrade" every such line we deal with by wrapping
        # it with our local bespoke class.
        #
        #   • if we were to upgrade all such lines in a section upfront
        #     it would be wasteful and slog-causing for most tests.
        #
        #   • not to cache such an upgrade once it has been done would also
        #     be wasteful and cause slog to the extent that we would
        #     otherwise ever need to traverse and match into a same line
        #     twice (which happens when we do "random access" search on the
        #     same section in different tests in a test suite).
        #
        # an OCD but risky approach would be "concat" two streams, one that
        # draws from the existing cache and (once this stream is exhausted)
        # a second stream that adds to the cache.
        #
        # this is all fine and pretty UNLESS you ever have multiple streams
        # from the same section and you step them in a staggered manner.
        # because of how nasty this would be to debug if it ever happened,
        # we are *not* taking this OCD approach, and rather we are just
        # checking the cache length at each step.

        cache_a = ( @_line_cache ||= [] )

        cache = -> d do
          x = Line___.new @_a.fetch d
          cache_a[ d ] = x
          x
        end

        Callback_::Stream.via_times @_a.length do |d|
          cache_a[ d ] || cache[ d ]
        end
      end

      def first_string
        @_a.fetch( 0 ).string
      end
    end

    # ==

    class Regex_Based_Matcher__

      def initialize rx
        @_rx = rx
        @subject_noun_phrase = nil
      end

      def styled  # so :#here
        @_prepare_matchee_method = :__expect_styled
        NIL_
      end

      def line_offset= d
        @_matcher_method = :__match_line_by_offset
        @line_offset = d
      end

      attr_writer(
        :subject_noun_phrase,
      )

      def for s, ctx
        dup.___init_for s, ctx
      end

      def ___init_for s, ctx
        @_context_x = ctx
        @_first_match_content = s
        self
      end

      def matches? section

        # (this violates etc..)
        @_section = section
        send @_matcher_method
      end

      def __match_line_by_offset
        @_li = @_section.line_at_offset @line_offset
        send @_prepare_matchee_method  # raises on failure
        @_md = @_rx.match @_s
        if @_md
          _actual_s = @_md[ 1 ]
          if _actual_s == @_first_match_content
            ACHIEVED_
          else
            @_failure_message_method = :__say_first_capture_didnt_match
            _fail
          end
        else
          @_failure_message_method = :__say_string_didnt_match
          _fail
        end
      end

      def failure_message_for_should
        send @_failure_message_method
      end

      def __say_string_didnt_match
        "expected #{ _subj } to match /#{ @_rx.source }/ - #{ @_s.inspect }"
      end

      def __say_first_capture_didnt_match
        "expected #{ _subj } part to be #{ @_first_match_content.inspect }, #{
          }had #{ @_md[ 1 ].inspect }"
      end

      def _subj
        @subject_noun_phrase || 'string'
      end

      def __expect_styled
        @_s = @_li.unstyled_styled  # raises
      end

      def _fail

        if @_context_x.respond_to? :quickie_fail_with_message_by
          _p = method @_failure_message_method
          @_context_x.quickie_fail_with_message_by( & _p )
          NIL_
        else
          false
        end
      end
    end

    # ==

    class Item_Pair_Matcher___

      def initialize opt_sym, a, b, x

        @a_s = a
        @b_s = b
        @_context_x = x

        if opt_sym
          send opt_sym
        else
          @_styled = nil
          @_init_string = :__init_string_as_is
        end
      end

      def styled
        @_styled = true
        @_init_string = :__init_string_when_maybe_styled ; nil
      end

      def matches? section

        st = section.to_line_stream
        st.gets
        content_line_count = 0

        begin
          @_li = st.gets
          if @_li
            send @_init_string
            @_md = PAIR___.match @_s
            s = @_md[ 1 ]
            if s
              content_line_count += 1
              if @a_s == @_md[ 1 ]
                if @b_s == @_md[ 2 ]
                  found = true
                  break
                end
                @_reason_m = :__say_second_one_didnt_match
                break
              end
            end
            redo
          end
          @_d = content_line_count
          @_reason_m = :__say_not_found
          break
        end while nil

        if found
          if @_styled
            if @_li.is_styled
              true
            else
              @_reason_m = :__say_was_not_styled
              _fail
            end
          else
            true
          end
        else
          _fail
        end
      end

      def __init_string_as_is
        @_s = @_li.string ; nil
      end

      def __init_string_when_maybe_styled
        @_s = @_li.unstyled ; nil
      end

      PAIR___ = %r(\A(?:[ ]{2,}((?:(?!  ).)+)(?:[ ]{2,}(.+))?)?$)

      def _fail
        if @_context_x.respond_to? :quickie_fail_with_message_by
          _p = method @_reason_m
          @_context_x.quickie_fail_with_message_by( & _p )
          nil
        else
          false
        end
      end

      def failure_message_for_should
        send @_reason_m
      end

      def __say_second_one_didnt_match
        "needed #{ @b_s.inspect }, had #{ @_md[ 2 ].inspect }"
      end

      def __say_not_found
        "not found: #{ @a_s.inspect } (in #{ @_d } item lines)"
      end

      def __say_was_not_styled
        "expected to be styled, was not - #{ @_li.string.inspect }"
      end
    end

    # ==

    class Line___

      def initialize li
        @_did = false
        @_vendor_line = li
      end

      def unstyled
        @_did || _do
        @_unstyled_string
      end

      def unstyled_styled
        if is_styled
          @_unstyled_string
        else
          fail ___say_was_not_styled
        end
      end

      def ___say_was_not_styled
        "was not styled - #{ @_vendor_line.string.inspect }"
      end

      def is_styled
        @_did || _do
        @__is_styled
      end

      def _do

        @_did = true

        s = @_vendor_line.string
        s_ = Styling___[]::Unstyle_styled[ s ]
        if s_
          is = true
          s = s_
        end

        @__is_styled = is
        @_unstyled_string = s ; nil
      end

      def _unstyled_string
        @_unstyled_string
      end

      Styling___ = Lazy_.call do
        Home_.lib_.brazen::CLI_Support::Styling
      end

      def string
        @_vendor_line.string
      end
    end

    # ==

    Coarse_pass__ = -> lines do

      # this is a way dumbed-down, bespoke variant of aforementioned mentors:
      # the object is global infallibility with local fallibility: we parse
      # the whole screen in one "coarse pass" with a syntax that is
      # relatively lenient: it requires only that there is at least one line
      # and that the first line's first byte is [a-z].
      #
      # this "coarse pass" puts the lines of the screen into "buckets"
      # corresponding to what "section" the line is in, where a "section"
      # is simply one line whose first byte is [a-z] followed by zero or
      # more lines that are not this.
      #
      # a section is simply an array of lines, and this array is put into
      # a hash keyed to the first "word" of the first line. (this is not
      # clobber-proof.)
      #
      # then, particular methods that assert specifics about content use one
      # (if found) particular "bucket" created in the coarse run, and fail
      # as appropriate for what is being tested. the desired outcome of this
      # is that a failure to match one piece won't cause the whole house of
      # cards to come crashing down.
      #
      # issues/wishlist:
      #
      #   • some body copy changes will break the bucket names, but this
      #     is perhaps es muss sein
      #
      #   • this does not hold the test context, so all fails are hard..
      # -
        h = {}
        st = Callback_::Polymorphic_Stream.via_array lines

        li = nil ; s = nil

        gets_one = -> do
          li = st.gets_one
          s = li.string
          if E__ == s.getbyte( 0 )
            s = Unstyle_styled__[ s ]
          end
        end
        gets_one[]

        word_s = WORD_RX__.match( s )[ 0 ]

        a = nil
        start_bucket = -> do
          a = []
        end
        start_bucket[]
        finish_bucket = -> do
          h[ word_s.intern ] = a
          a = nil ; word_s = nil
        end

        begin
          a.push li
          if st.no_unparsed_exists
            finish_bucket[]
            break
          end
          gets_one[]

          md = WORD_RX__.match s
          if md
            finish_bucket[]
            start_bucket[]
            word_s = md[ 0 ]
            redo
          end
          redo
        end while nil

        h
      # -
    end

    # ==

    p = nil
    Unstyle_styled__ = -> s do
      p ||= Home_.lib_.brazen::CLI_Support::Styling::Unstyle_styled
      p[ s ]
    end

    E__ = "\e".getbyte 0

    WORD_RX__ = /\A[a-z]+/

    Here_ = self
  end
end
