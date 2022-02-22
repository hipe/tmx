module Skylab::Zerk::TestSupport

  class CLI::Want_Section_Coarse_Parse  # (as class, re-opens #here3)

    # the fourth of #[#054], this is :[#054.4] (a blind rewrite)
    #
    # the subject's philosophy is encapsulated succinctly #here2.
    #
    # (although there is a fifth in this strain, subject is last ever file.)
    #
    # as a test file enhancement it's used (~13x) in [ze] and ~3x in [cm].
    #
    # but its "coarse parse" function sees wide use also, hence its name change

    def self.[] tcc
      Use_::Memoizer_methods[ tcc ]
      TS_::Non_Interactive_CLI[ tcc ]
      tcc.send :define_singleton_method, :given_screen, Given_screen___
      tcc.include InstanceMethods__
    end

    # -
      Given_screen___ = -> & p do

        given( & p )

        yes = true ; x = nil
        define_method :niCLI_help_screen do
          if yes
            yes = false
            x = __build_hsz_screen
          end
          x
        end
      end
    # -

    Magnetics = ::Module.new  # for here and sibling (maybe not used there)

    module InstanceMethods__

      # -- methods that produce subjects

      # ~ usage line

      def build_index_of_first_usage_line

        # (experimental code sketch - use a rough regex to break the usage
        # line into its parts, based on some axioms of character usage.)

        _ = section( :usage ).first_line.unstyled_styled
        build_index_of_this_unstyled_usage_line _
      end

      def build_index_of_this_unstyled_usage_line mutable_s
        Magnetics::SlugIndexBox_via_MutableString[ mutable_s ]
      end
    end  # (re-opens)

    module Magnetics

      SlugIndexBox_via_MutableString = -> s do
        SlugIndexBox_via_SlugArray[ SlugArray_via_MutableString[ s ] ]
      end

      SlugArray_via_MutableString = -> mutable_s do
        mutable_s.chomp!
        _s_a = mutable_s.split %r([ ](?=(?:[-a-z:]+|\[[^\]]+|<[^>]+)))  # #open [#bm-002] (benchmarks)
        _s_a
      end

      SlugIndexBox_via_SlugArray = -> _s_a do
        bx = Common_::Box.new
        _s_a.each do |s_|
          bx.add s_, s_
        end
        bx
      end
    end

    module InstanceMethods__  # (re-open)

      # ~ options

      def build_index_of_option_section section=nil

        ( section || self.section( :options ) ).to_option_index
      end
    end

    # ==

    class Section__  # #re-opens

      def to_option_index
        Magnetics::OptionIndex_via_LineEmissionStream[ to_line_stream ]
      end
    end

    module Magnetics

      OptionIndex_via_LineEmissionStream = -> st do

        bx = Common_::Box.new
        st.gets  # skip header line
        ol = nil  # implicitly enforces a syntax
        begin
          line = st.gets
          line || break

          if line.is_styled
            was_styled = true
            s = line._unstyled_string  # VIOLATION
          else
            was_styled = false
            s = line.string
          end

          md = OPTION_LINE_RX__.match s

          if md
            ol = OptionItem___.new was_styled, * md.captures
            s = ol.short
            if s
              bx.add s, ol
            else
              bx.add ol.long, ol
            end
            redo
          end

          if line.is_blank_line  # this might change
            redo
          end

          ol.__add_additional_line line
          redo
        end while nil
        bx
      end
    end

    # ==

      OPTION_LINE_RX__ = %r(\A
          [ ]{2,}
          (?: (?<short>-[a-z]),[ ] )?
          (?<long>--(?:(?![ ][ ]).)+)
          (?:[ ]{2,}(?<rest>[^ ].+))?
        \n\z)x

      class OptionItem___

        def initialize b, s, s_, s__
          @desc = s__
          @long = s_
          @short = s
          @was_styled = b
        end

        def __add_additional_line line
          ( @additional_lines ||= [] ).push line ; nil
        end

        def long_stem
          @long_stem ||= @long.match( RX___ )[ 0 ]
        end

        RX___ = %r([a-z]+(?:-[a-z]+)*)

        attr_reader(
          :additional_lines,
          :desc,
          :long,
          :short,
          :was_styled,
        )
      end

    # ==

    module InstanceMethods__  # (re-open)

      def section sym
        niCLI_help_screen.section sym
      end

      def __build_hsz_screen

        CoarseParse___.via_line_object_scanner Home_::Scanner_[ niCLI_state.lines ]
      end

      # -- methods that produce predicates (matchers)

      def be_description_line_of opt_sym=nil, exp_s
        o = Single_description_line___[].for exp_s, self
        if opt_sym
          o.send opt_sym  # :#here1, nasty
        end
        o
      end

      Single_description_line___ = Lazy_.call do
        RegexpBasedMatcher__.define do |o|
          o.regexp = %r(\Adescription: (.+)$)
        o.line_offset = 0
        o.subject_noun_phrase = "single description line"
        end
      end

      # ~ options

      def have_option sw, long_plus, desc=nil
        OptionIndexMatcher___.define do |o|
          if desc
            o.desc = desc
            o.want_desc_was_styled = true  # ..
          end
          o.short_switch = sw
          o.long_switch_plus = long_plus
          o.mixed_test_context = self
        end
      end

      def have_item_pair_of opt_sym=nil, a, b
        ItemPairMatcher__.define do |o|
          o.option_symbol = opt_sym
          o.left_column_cel_string = a
          o.right_column_cel_string = b
          o.mixed_test_context = self
        end
      end

      def be_item_pair opt_sym=nil, a, b
        ItemPairMatcher__.define do |o|
          o.will_match_against_line_object
          o.option_symbol = opt_sym
          o.left_column_cel_string = a
          o.right_column_cel_string = b
          o.mixed_test_context = self
        end
      end

      # ~

      def be_invite_line_of s
        Invite_line___[].for s, self
      end

      Invite_line___ = Lazy_.call do

        RegexpBasedMatcher__.define do |o|

          o.regexp = %r(\Ause 'xyzi ([^-]+) -h <action>' for help on that action\.$)

        o.line_offset = 0
        o.styled
        o.subject_noun_phrase = "invite line"
        end
      end

      # --

      def have_styled_line_matching rx

        regexp_based_matcher_by_ do |o|
          o.regexp = rx
        o.styled
        o.match_any_line  # must come after styled
          o.__be_instance_not_prototype_
        end
      end

      def regexp_based_matcher_by_ & p
        RegexpBasedMatcher__.define( & p )
      end
    end

    # ==

    CoarseParse___ = self  # #coverpoint
    class CoarseParse___  # also PUBLIC (per #here3)

      class << self

        def via_line_object_array a
          via_line_object_scanner Home_::Scanner_[ a ]
        end

        alias_method :via_line_object_scanner, :new
        undef_method :new
      end  # >>

      def initialize line_object_scn
        bx = CoarsePass_via_LineObjectScanner___[ line_object_scn ]
        @_a = bx.a_
        @_h = bx.h_
        @_section_cache = {}
      end

      def section_at_index d
        section @_a.fetch d
      end

      def section sym
        @_section_cache.fetch sym do
          _a = @_h.fetch sym
          x = Section__.new _a
          @_section_cache[ sym ] = x
          x
        end
      end

      def section_name_symbols
        @_h.keys  # meh
      end

      def section_count
        @_a.length
      end

      def has_section sym
        @_h.key? sym
      end
    end

    # ==

    class Section__  # re-opened

      def initialize a
        @raw_lines = a
      end

      def items
        @___items ||= __recurse
      end

      def __recurse

        _st = Common_::Stream.via_range( 1 ... @raw_lines.length ) do |d|
          @raw_lines.fetch d
        end

        Coarse_pass_recurse___[ _st ]
      end

      # --

      def first_line
        line_at_offset 0
      end

      def second_line
        line_at_offset 1
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
          x = Line___.new @raw_lines.fetch d
          cache_a[ d ] = x
          x
        end

        Common_::Stream.via_times @raw_lines.length do |d|
          cache_a[ d ] || cache[ d ]
        end
      end

      # --

      def first_string
        @raw_lines.fetch( 0 ).string
      end

      def raw_line d
        @raw_lines.fetch d
      end

      def line_count
        @raw_lines.length
      end

      attr_reader(
        :raw_lines,
      )
    end

    # ==

    class RegexpBasedMatcher__ < Common_::SimpleModel  # #testpoint

      def initialize
        @_resolve_matchee = :__resolve_matchee_as_is
        @subject_noun_phrase = nil
        @styled = false
        @_is_prototype = true
        yield self
        if remove_instance_variable :@_is_prototype
          freeze
        end
      end

      def __be_instance_not_prototype_  # #coverpoint3.1
        @_is_prototype = false ; nil
      end

      def styled  # so :#here1
        @_resolve_matchee = :__resolve_matchee_when_expecting_styled
        @styled = true
        NIL_
      end

      def line_offset= d
        @_match = :__match_line_by_offset
        @line_offset = d
      end

      def match_any_line  # must come after styled

        @_match = :__match_any_line
        if @styled
          @_resolve_matchee = :__resolve_matchee_by_unstyling_softly
        end
      end

      def regexp= rx
        @_rx = rx  # legacy name, for now. makes lines shorter
      end

      attr_writer(
        :subject_noun_phrase,
      )

      def for s=nil, ctx
        dup.___init_for s, ctx
      end

      def ___init_for s, ctx
        @_context_x = ctx
        @_first_match_content = s
        self
      end

      # ~( #open #[#033.3]

      def matches? section

        # (this violates etc..)
        @_section = section
        send @_match
      end

      def failure_message
        send @_failure_message_method
      end

      # ~)

      def __match_any_line
        d = 0
        st = @_section.to_line_stream
        begin
          @_li = st.gets
          @_li or break
          d += 1
          ok = _resolve_matchee
          ok &&= _resolve_matchdata_via_matchee
          if ok
            found = true
            x = _curate_finish_via_matchdata
            break
          end
          redo
        end while nil
        if found
          x
        else
          @_line_count = d
          _will_fail_with :__say_no_line_matching
        end
      end

      def __match_line_by_offset
        @_li = @_section.line_at_offset @line_offset
        ok = __curate_matchee
        ok &&= __curate_matchdata_via_matchee
        ok && _curate_finish_via_matchdata
      end

      def _curate_finish_via_matchdata
        yes = instance_variable_defined? :@_first_match_content
        if yes && @_first_match_content
          _actual_s = @_md[ 1 ]
          if _actual_s == @_first_match_content
            ACHIEVED_
          else
            _will_fail_with :__say_first_capture_didnt_match
          end
        else
          ACHIEVED_
        end
      end

      def __curate_matchdata_via_matchee
        if _resolve_matchdata_via_matchee
          ACHIEVED_
        else
          _will_fail_with :__say_string_didnt_match
        end
      end

      def _resolve_matchdata_via_matchee
        _store :@_md, @_rx.match( @_s )
      end

      def __curate_matchee
        if _resolve_matchee
          ACHIEVED_
        else
          _will_fail_with :__say_was_not_styled  # assume #here3
        end
      end

      def _resolve_matchee
        send @_resolve_matchee
      end

      def __resolve_matchee_when_expecting_styled  # #here3
        if @_li.is_styled
          @_s = @_li.unstyled_styled  # raises
          ACHIEVED_
        end
      end

      def __resolve_matchee_by_unstyling_softly
        @_s = @_li.unstyled
        ACHIEVED_
      end

      def __resolve_matchee_as_is
        @_s = @_li.string
        ACHIEVED_
      end

      def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        if x
          instance_variable_set ivar, x ; ACHIEVED_
        else
          UNABLE_
        end
      end

      def __say_was_not_styled
        @_li.say_was_not_styled
      end

      def __say_no_line_matching
        "no lines matched /#{ @_rx.source }/ (of #{ @_line_count } line(s))"
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

      def _will_fail_with m
        if @_context_x.respond_to? :quickie_fail_with_message_by
          _p = method m
          @_context_x.quickie_fail_with_message_by( & _p )
        else
          @_failure_message_method = m
        end
        UNABLE_
      end
    end

    # ==

    class OptionIndexMatcher___ < Common_::SimpleModel  # #testpoint

      # ~( ivars are legacy names

      def initialize
        @desc = nil
        @want_desc_was_styled = nil
        yield self
        # can't freeze while #open [#ts-033.3]
      end

      def new  # (compare self::DEFINITION_FOR_THE_METHOD_CALLED_REDEFINE)
        otr = dup
        yield otr
        otr
      end

      def long_switch_plus= s
        @long = s
      end

      def short_switch= s
        @sw = s
      end

      def mixed_test_context= x
        @ctx = x
      end

      # ~)

      attr_writer(
        :want_desc_was_styled,
        :desc,
      )

      # ~( #open [#ts-033.3]

      def matches? idx
        @_index = idx  # eew/meh
        ok = __short
        ok &&= __long
        ok &&= __desc
        ok && __styled
      end

      def failure_message
        send @__m
      end

      # ~)

      def __short
        @_ol = @_index[ @sw ]
        if @_ol
          ACHIEVED_
        else
          _fail_by :___say_no_short
        end
      end

      def ___say_no_short
        "no #{ @sw.inspect } - had #{ @_index.a_.inspect }"
      end

      def __long
        if @_ol.long == @long
          ACHIEVED_
        else
          _fail_by :___say_no_long
        end
      end

      def ___say_no_long
        "wanted #{ @long.inspect }, had #{ @_ol.long.inspect }"
      end

      def __desc
        if @_ol.desc == @desc
          ACHIEVED_
        else
          _fail_by :___say_no_desc
        end
      end

      def ___say_no_desc
        "desc didn't match. wanted #{ @desc.inspect }, had #{ @_ol.desc.inspect }"
      end

      def __styled
        if @want_desc_was_styled
          if @_ol.was_styled
            ACHIEVED_
          else
            _fail_by :___say_no_styled
          end
        else
          ACHIEVED_
        end
      end

      def ___say_no_styled
        "item description was not styled - #{ @_ol.desc.inspect }"  # #here4
      end

      def _fail_by m
        if @ctx.respond_to? :quickie_fail_with_message_by
          @ctx.quickie_fail_with_message_by( & method( m ) )
          nil
        else
          @__m = m
          UNABLE_
        end
      end
    end

    # ==

    class ItemPairMatcher__ < Common_::SimpleModel  # #testpoint

      def initialize
        @_match = :__match_section
        yield self
        # no freeze for now..
      end

      # ~( legacy ivar names

      def option_symbol= opt_sym
        if opt_sym
          send opt_sym
        else
          @_styled = nil
          @_init_string = :__init_string_as_is
        end
        opt_sym
      end

      def left_column_cel_string= s
        @a_s = s
      end

      def right_column_cel_string= s
        @b_s = s
      end

      def mixed_test_context= x
        @_context_x = x
      end

      # ~)

      def will_match_against_line_object
        @_match = :__match_line ; nil
      end

      def styled
        @_styled = true
        @_init_string = :__init_string_when_maybe_styled ; nil
      end

      # ~( #open #[#ts-003.3]

      def matches? x
        send @_match, x
      end

      def failure_message
        send @_reason_m
      end

      # ~)

      def __match_section section

        st = section.to_line_stream
        st.gets
        content_line_count = 0

        begin
          @_li = st.gets
          if ! @_li
            @_d = content_line_count
            @_reason_m = :__say_not_found
            break
          end

          _init_matchdata
          if ! @_md[ :right_cel ]
            redo
          end

              content_line_count += 1
              found = _evaluate_content
              found and break
              @_reason_m and break
            redo
        end while nil

        if found
          _when_found_content
        else
          _fail
        end
      end

      def __match_line li
        @_li = li
        _init_matchdata
        _ok = _evaluate_content
        if _ok
          _when_found_content
        else
          @_reason_m ||= :__say_first_one_didnt_match
          _fail
        end
      end

      def _init_matchdata

        send @_init_string
        @_md = %r(\A(?:
          [ ]{2,}  # require that there be a margin of two (possibly more) spaces
          (?<left_cel>
            (?:(?![ ]{2}).)+  # one space does not break the first cel, 2 does
          )
          (?:
            [ ]{2,}  # if there is a two (or more) space separator,
            (?<right_cel> .+ )  # match whatever till the end of the line
          )?  # but this whole right side is optional
        )?  # also match on blank lines
        $)x.match @_s
      end

      def _evaluate_content
        if @a_s == @_md[ 1 ]
          if @b_s == @_md[ 2 ]
            @_reason_m = nil
            ACHIEVED_
          else
            @_reason_m = :__say_second_one_didnt_match
            UNABLE_
          end
        else
          @_reason_m = nil
          UNABLE_
        end
      end

      def _when_found_content
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
      end

      def __init_string_as_is
        @_s = @_li.string ; nil
      end

      def __init_string_when_maybe_styled
        @_s = @_li.unstyled ; nil
      end

      def _fail
        if @_context_x.respond_to? :quickie_fail_with_message_by
          _p = method @_reason_m
          @_context_x.quickie_fail_with_message_by( & _p )
          nil
        else
          false
        end
      end

      def __say_second_one_didnt_match
        "in second cel, #{ _say_wanted_had @_md[2], @b_s }"
      end

      def __say_first_one_didnt_match
        "in first cel, #{ _say_wanted_had @_md[1], @a_s }"
      end

      def _say_wanted_had act_s, exp_s
        "wanted #{ exp_s.inspect }, had #{ act_s.inspect }"
      end

      def __say_not_found
        "not found: #{ @a_s.inspect } (in #{ @_d } item lines)"
      end

      def __say_was_not_styled
        @_li.say_was_not_styled
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
          fail say_was_not_styled
        end
      end

      def say_was_not_styled
        "line was not styled - #{ @_vendor_line.string.inspect }"  # #here4
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
        Home_::CLI::Styling
      end

      def is_blank_line
        NEWLINE_ == @_vendor_line.string
      end

      def string
        @_vendor_line.string
      end
    end

    # ==

    CoarsePass_via_LineObjectScanner___ = -> line_object_scn do

      # :#here2:
      #
      # this is a way dumbed-down, bespoke variant of aforementioned mentors:
      # the objective is global infallibility with local fallibility: we
      # parse the whole screen in one "coarse pass" with a syntax that is
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
        bx = Common_::Box.new

        li = nil ; s = nil

        gets_one = -> do
          li = line_object_scn.gets_one
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
          bx.add word_s.intern, a
          a = nil ; word_s = nil
        end

        begin
          a.push li
          if line_object_scn.no_unparsed_exists
            finish_bucket[]
            break
          end
          gets_one[]

          md = WORD_RX__.match s
          if md
            finish_bucket[]
            start_bucket[]
            word_s = md[ 0 ]
          end
          redo
        end while nil

        bx
      # -
    end

    # ==

    Coarse_pass_recurse___ = -> st do

      # exactly a simplified [#ba-043]

      # (regexen here are written with spaces only but to add support
      #  for tabs "should be" trivial.)

      sections = []
      line = st.gets
      begin
        line or break

        sect = SubSection___.new line
        sections.push sect

        _md = %r(\A[ ]+(?=[^ ])).match line.string  # sanity..

        marginator_rx = %r(\A#{ ::Regexp.escape _md[ 0 ] }[ ]+)

        line = st.gets
        begin
          line or break

          # if the line is one level of indent **or more** deeper
          # than the line, classify it as a body line.

          if marginator_rx =~ line.string
            sect._add_body_line line
            line = st.gets
            redo
          end

          # any one or more contiguous blank lines are always included
          # in the body and do not break the section (for now).

          begin
            if BLANK_RX___ =~ line.string
              sect._add_body_line line
              line = st.gets
              line or break
              redo
            end
            break
          end while nil

          # if it's neither of the above then let's assume its superior..

          break
        end while nil

        redo
      end while nil

      sections
    end

    # ==

    class SubSection___

      def initialize o
        @head_line = o
      end

      def _add_body_line o
        ( @body_lines ||= [] ).push o ; nil
      end

      attr_reader(
        :body_lines,
        :head_line,
      )
    end

    # ==

    Unstyle_styled__ = -> s do
      Home_::CLI::Styling::Unstyle_styled[ s ]
    end

    BLANK_RX___ = %r(\A$)  # be indifferent to newlines
    E__ = "\e".getbyte 0
    Here_ = self
    WORD_RX__ = /\A[a-z]+/
  end
end
# #history-A.1: got coverage years later, some refactoring.
