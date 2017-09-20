module Skylab::Zerk::TestSupport

  class CLI::Expect_Section_Fail_Early

    # the first of four similar facilities, this is :[#054.1] of #[#054]

    # this also contains a fifth addition to the family strain, a
    # "fail early"-modeled one.

    # the oldschool based one:

    # in one go, parse a whole "screen" with indentation-sensitive syntax
    # reminiscent of a super simplified python or OGDL. the result data
    # structure is geared towards assertion.

    # :#gotcha #subscribed - if the treeifier encounters a blank like (i.e
    # only a newline), what it does is context dependant: if it's in the
    # middle of a multiline node, it adds it to that node. otherwise it
    # counts the newline as its own toplevel item. this annoys some clients
    # and might change somehow, but for now it is just being watched ..
    # :[#here.1-1].

    PUBLIC = true

    class << self

      def tree_via * x_a
        o = Help_Screen_State._begin
        o.process_iambic_fully x_a
        o._build_tree
        o._finish
        o.tree
      end
    end  # >>

#==FROM

    class << self

      def define
        if block_given?
          o = new
          yield o
          o.finish
        else
          new
        end
      end

      private :new
    end  # >>

    # -
      def initialize
        @_expectations = []
      end

      def expect_section header_s, & p
        @_expectations.push SectionExpectation___.new p, header_s ; nil
      end

      def finish
        self
      end

      def to_spy_under test_context
        Spy___.new test_context, @_expectations
      end
    # -

    # ==

    class Spy___

      def initialize tc, exp_a

        @_expectation_scanner = Common_::Scanner.via_array exp_a
        @spying_IO = Spying_IO___.new self
        @test_context = tc
        _reinit_state
      end

      def receive_emission data, method_name

        @_current_emission = ActualEmission___.new data, method_name

        if @test_context.do_debug
          __express_debugging_for_emission
        end

        send @_step
        NIL
      end

      def __express_debugging_for_emission
        @test_context.debug_IO.puts @_current_emission._inspect_
        NIL
      end

      def __dispatch_emission_to_assertion
        _directive_symbol = @_assertion.receive_emission @_current_emission
        send DIRECTIVES___.fetch _directive_symbol
        NIL
      end

      DIRECTIVES___ = {
        _finished_: :_when_assertion_is_finished,
        _pop_: :__pop,
        _stay_: :__no_op,
      }

      def __pop
        _when_assertion_is_finished
        send @_step
        NIL
      end

      def _when_assertion_is_finished
        remove_instance_variable :@_assertion
        @_expectation_scanner.advance_one
        _reinit_state
      end

      def __no_op
        NOTHING_
      end

      def _reinit_state

        if @_expectation_scanner.no_unparsed_exists
          @_step = :__process_emission_when_expecting_no_more_emissions
        else
          @_assertion = @_expectation_scanner.head_as_is.begin_assertion_under @test_context
          @_step = :__dispatch_emission_to_assertion
        end
        NIL
      end

      def __process_emission_when_expecting_no_more_emissions
        fail AssertionFailed, "expected no more emissions, had: #{ @_current_emission._inspect_ }"
      end

      def finish
        remove_instance_variable( :@_assertion )._become_finished
        @_expectation_scanner.advance_one
        if @_expectation_scanner.no_unparsed_exists
          remove_instance_variable :@_expectation_scanner
          NIL
        else
          fail AssertionFailed, __say_unresolved_expectation
        end
      end

      def __say_unresolved_expectation
        _ = @_expectation_scanner.head_as_is.noun_phrase
        "at end of output, expected but never reached #{ _ }"
      end

      attr_reader(
        :spying_IO,
      )
    end

    # ==

    class Spying_IO___  # an ultra-simple form of #[#sy-039.1] such proxies

      def initialize o
        @client = o
      end

      def puts s=nil
        @client.receive_emission s, :puts
        NIL
      end
    end

    # ==

    class BuildSection___

      def initialize tc, rs_p, header_s
        @emissions = []
        @header_string = header_s
        @_receive = :__receive_first_emission
        @receive_section = rs_p
        @test_context = tc
      end

      def receive_emission em
        send @_receive, em
      end

      def __receive_first_emission em
        if Is_blank_line_emission__[ em ]
          fail AssertionFailed, __say_expecting_string_but_had_none
        else
          s = em.string
          md = SECTION_OPENER_RX___.match s
          if md
            if @header_string == md[ :header ]
              @emissions.push em
              @_receive = :_receive_subsequent_emission_normally
              :_stay_
            else
              fail AssertionFailed, __say_expected_header( md[ :header ] )
            end
          else
            fail AssertionFailed, __say_expecting_match(s)
          end
        end
      end

      def __say_expected_header s
        "expected header of #{ @header_string.inspect }, had #{ s.inspect }"
      end

      def __say_expecting_match s
        "expected opening of section, had: #{ s.inspect }"
      end

      def __say_expecting_string_but_had_none
        "expected section with header #{ @header_string.inspect }, had blank line"
      end

      def _receive_subsequent_emission_normally em

        if Is_blank_line_emission__[ em ]
          __receive_locally_first_blank_line em
        else
          s = em.string
          if INDENTED_RX__ =~ s
            @emissions.push em
            :_stay_
          else
            fail AssertionFailed, __say_annoying(s)
          end
        end
      end

      def __receive_locally_first_blank_line em
        # this blank line, we don't know if it separates a section or
        # a subsection until we get the next line. life is easer if we:
        @emissions.push em
        @_receive = :__receive_line_after_mystery_blank_line
        :_stay_
      end

      def __receive_line_after_mystery_blank_line em

        Is_blank_line_emission__[ em ] && self._SANITY__readme__
          # two blank lines in a row is perhaps unheard of

        if INDENTED_RX__ =~ em.string
          @emissions.push em
          @_receive = :_receive_subsequent_emission_normally
          :_stay_
        else
          _become_finished
          :_pop_
        end
      end

      def __say_annoying s
        "this might change later, but for now, unexpected not indented line: #{ s.inspect }"
      end

      def _become_finished

        remove_instance_variable :@_receive

        _tc = remove_instance_variable :@test_context
        _em = remove_instance_variable( :@emissions ).freeze
        _p = remove_instance_variable :@receive_section

        _p[ Section___.new( _em, _tc ) ]

        NIL
      end
    end

    # ==

    class Section___

      def initialize em_a, tc
        @emissions = em_a
        @_test_context = tc
      end

      def to_index_of_common_branch_usage_line  # [tmx] [bs]
        Magnetics__[]::CommonBranchUsageLineIndex_via_Line[ _first_line ]
      end

      def to_index_of_common_operator_usage_line
        Magnetics__[]::CommonOperatorUsageLineIndex_via_Line[ _first_line ]
      end

      def to_index_of_common_item_list_EXPERIMENTAL_ALTERNATIVE  # (see)
        _st = _to_string_stream
        Magnetics__[]::CommonItemsSection_via_LineStream_EXPERIMENTAL_ALTERNATIVE[ _st ]
      end

      def to_index_of_common_item_list
        _st = _to_string_stream
        Magnetics__[]::CommonItemsSection_via_LineStream[ _st ]
      end

      def expect_exactly_one_line
        expect_number_of_lines 1
        _first_line
      end

      def _first_line
        @emissions.fetch( 0 ).string
      end

      def expect_number_of_lines d
        expect_range_of_lines d..d
      end

      def expect_range_of_lines r
        d = number_of_lines
        if r.include? d
          true
        else
          fail __say_range( d, r )
        end
      end

      def __say_range d, r
        _ = r.end == r.begin ? r.begin.to_s : r.inspect
        "expected #{ _ } line(s) in section had #{ d }"
      end

      def number_of_lines
        num = @emissions.length
        if Is_blank_line_emission__[ @emissions.last ]
          num -= 1
        end
        num
      end

      def _to_string_stream

        muta = nil

        Stream_.call @emissions do |em|
          em.string || ( muta ||= '' )
        end
        # (because `chomp!` is used, string can't be the frozen EMPTY_S_)
      end

      def TO_LINE_STRINGS  # not covered but useful in debugging
        @emissions.map { |em| em.string }
      end

      attr_reader(
        :emissions
      )
    end

    # ==

    class ActualEmission___

      def initialize string, m
        @method_name = m
        @string = string
      end

      def _inspect_
        [ @method_name, @string ].inspect
      end

      attr_reader(
        :method_name,
        :string,
      )
    end

    # ==

    class SectionExpectation___

      def initialize p, header
        @header_string = header
        @receive_section = p
      end

      def begin_assertion_under tc
        BuildSection___.new tc, @receive_section, @header_string
      end

      def noun_phrase
        "a section with header #{ @header_string.inspect }"
      end
    end

    # ==

    SECTION_OPENER_RX___ = /\A
      (?<header> [a-z] [-a-z_ 0-9]+ )
      (?:
          :?$  # optionally a colon, and then the end of the line OR
        |

          :[ ]+(?<rest>[^ ].*)
               # necessarily a colon, one or more space, then some content
      )
    /ix

    INDENTED_RX__ = /\A {2,}[^ ]/

    # ==

    AssertionFailed = ::Class.new ::RuntimeError

    # ==
#==TO

    # -- (forward declarations)

    Leaf_Node__ = ::Class.new
    Branch_Node__ = ::Class.new Leaf_Node__

    # -- conversion methods

    class Branch_Node__

      def to_column_B_string m

        # where "column" is defined as those spans of text that are
        # delimited by by *two* or more spaces on each relevant side.

        st = _to_full_pre_order_stream
        s = st.gets.x.send m

        md = RX___.match s

        begin_ = md.offset( :col_B ).first
        r = begin_ .. -1

        a = []
        begin

          if s.length <= begin_
            a.push s
          else
            a.push s[ r ]  # including trailing newline
          end
          node = st.gets
          node or break
          s = node.x.send m
          redo
        end while nil

        a.join EMPTY_S_
      end

      RX___ = /^[ ]{2,}(?<col_A>(?:(?![ ]{2}).)+)[ ]{2,}(?<col_B>.+)/m

      def to_body_string m

        to_pre_order_stream.join_into "" do |node|
          node.x.send m
        end
      end

      def to_string m

        _to_full_pre_order_stream.join_into "" do |node|
          node.x.send m
        end
      end

      def to_body_lines m  # see next

        to_pre_order_stream.map_by do | node |
          node.x.send( m ).chomp!
        end.to_a
      end

      def to_lines m  # NOTE WARNING mutates originals!

        _to_full_pre_order_stream.map_by do | node |
          node.x.send( m ).chomp!
        end.to_a
      end

      def to_emission_stream  # assume not called on root

        _to_full_pre_order_stream.map_by do | node |
          node.x  # our native emission structure, that looks like a "Line" structure
        end
      end
    end

    class Leaf_Node__

      def to_emission_stream

        Common_::Stream.via_item @x
      end
    end

    # -- traversal methods

    class Leaf_Node__

      def _to_full_pre_order_stream
        Common_::Stream.via_item self
      end
    end

    module Parent_Methods__

      def to_pre_order_stream
        st = _to_full_pre_order_stream
        st.gets
        st
      end

      def _to_full_pre_order_stream

        # (note this would not scale well to large trees - each `gets` call
        # always cascades down from parent to child, always starting from
        # root. [#ba-053] is perhaps an improvement, but meh: help screens
        # are usually max depth 2..)

        cx_st = nil
        node_st = nil
        p = nil
        up = nil

        down = -> do
          cx = cx_st.gets
          if cx
            node_st = cx._to_full_pre_order_stream
            p = up
            p[]
          end
        end

        up = -> do
          node = node_st.gets
          if node
            node
          else
            node_st = nil  # sanity
            p = down
            p[]
          end
        end

        p = -> do
          cx_st = ___to_child_stream
          p = down
          self
        end

        Common_.stream do
          p[]
        end
      end

      def ___to_child_stream
        Common_::Stream.via_nonsparse_array @children
      end
    end

    # --

    class Help_Screen_State  # PUBLIC

      # encapsulate the parse tree, an index into its sections,
      # and an exitstatus.

      class << self

        def via * x_a
          via_iambic x_a
        end

        def via_iambic x_a
          o = _begin
          o.process_iambic_fully x_a
          o._build_tree
          o.__index_section_titles
          o._finish
          o
        end

        alias_method :_begin, :new
        private :new
      end  # >>

      def initialize
        @_build = Build__.new
      end

      def process_iambic_fully x_a

        st = Common_::Scanner.via_array x_a
        @_argument_scanner_narrator_ = st
        begin
          _m = st.gets_one
          _kp = send :"#{ _m }="
          _kp or fail
        end until st.no_unparsed_exists
        remove_instance_variable :@_argument_scanner_narrator_
        NIL_  # ..
      end

      def lax_parsing=
        @_build.become_lax
        KEEP_PARSING_
      end

      def state=
        state = @_argument_scanner_narrator_.gets_one
        @exitstatus = state.exitstatus
        @_build.emission_array = state.lines
        KEEP_PARSING_
      end

      def stream=
        @_build.stream_symbol = @_argument_scanner_narrator_.gets_one
        KEEP_PARSING_
      end

      def string=
        @_build.one_big_string = @_argument_scanner_narrator_.gets_one
        KEEP_PARSING_
      end

      def _build_tree
        build = remove_instance_variable :@_build
        @tree = build.execute
        @stream_set = build.stream_set
        NIL_
      end

      def __index_section_titles

        bx = Common_::Box.new

        @tree.children.each_with_index do | node, d |

          s = node.x.unstyled_header_content
          if s.length.nonzero?
            bx.add s, d
          end
        end

        @_index_box = bx
        NIL_
      end

      def _finish
        NIL_
      end

      # -

      attr_reader(
        :exitstatus,
        :stream_set,
        :tree,
      )

      def lookup unstyled_header_s
        @tree.children.fetch lookup_index unstyled_header_s
      end

      def lookup_index unstyled_header_s
        had = true
        d = @_index_box.fetch unstyled_header_s do
          had = false
        end
        if had
          d
        else
          raise ::KeyError, ___say( unstyled_header_s )
        end
      end

      def ___say s
        _s_a = @tree.children.map do | cx |
          cx.x.unstyled_header_content.inspect
        end
        "section #{ s.inspect } not found. (had: #{ _s_a * ', ' })"
      end
    end

    class Build__

      def initialize
        @_be_lax = false
        @stream_symbol = NO_STREAM__
      end

      attr_writer(
        :stream_symbol,
      )

      def become_lax
        @_be_lax = true ; nil
      end

      def emission_array= a
        _em_st = Common_::Stream.via_nonsparse_array a
        _receive_upstream_emission_stream _em_st
        a
      end

      def one_big_string= s

        scn = Basic_[]::String::LineStream_via_String[ s ]

        _em_st = Common_.stream do

          line = scn.gets
          if line
            Line_Emission___.new line, NO_STREAM__
          end
        end
        _receive_upstream_emission_stream _em_st
        s
      end

      NO_STREAM__ = :_no_stream_  # (or you could use nil, should be same)

      def _receive_upstream_emission_stream em_st
        # (process later - we need multiple ivars in place)
        @_upstream_emission_stream = em_st
        NIL_
      end

      def execute
        ___init_normal_upstream_emission_stream
        if @_be_lax
          __parse_jagged_tree
        else
          __parse_regular_tree
        end
      end

      def ___init_normal_upstream_emission_stream

        # a hand-written map-reduce of the incoming stream that primarily
        # A) reduces what it produces to only those emissons on the stream
        # of interest and B) secondarily memoizes each stream symbol seen
        # so that at the end (if it is ever reached) we will init a set of
        # all streams that were seen.

        seen_h = {}
        target_sym = @stream_symbol

        em_st = remove_instance_variable :@_upstream_emission_stream

        _my_st = Common_.stream do
          begin
            em = em_st.gets
            if em
              sym = em.stream_symbol
              seen_h[ sym ] = nil
              if target_sym == sym
                break
              end
              redo  # not on the right stream so try next line
            end
            # no more lines so..
            if seen_h  # only the first time we `gets` at end of stream
              @stream_set = seen_h.keys.sort.freeze
              seen_h = nil  # if the upstream stops and starts again, boom
            end
            break
          end while nil
          em
        end

        @_normal_upstream_emission_stream = _my_st

        NIL_
      end

      attr_reader :stream_set  # written above, at end of stream

      def __parse_jagged_tree

        # not as complex as the "regular" parser. there are only two real
        # states - deep and shallow. makes a tree of a limited depth based
        # on whether the line has a nonzero margin.

        frame = nil
        line = nil
        stack = nil

        take = -> do
          frame.a.push Amorphous__.new line
          NIL_
        end

        push = -> do
          _amo = Amorphous__.new line
          frame_ = Frame__.new line.margin_length, [ _amo ]
          stack.push frame_
          frame = frame_ ; nil
        end

        p = -> do

          frame = Frame__.new 0, []
          stack = [ frame ]
          @stack = stack

          shallow_state = nil
          initial_state = -> do

            if line.has_no_content
              self._NEVAR

            elsif line.margin_length.zero?

              take[]
              p = shallow_state

            else
              self._NEVAR
            end
          end

          deep_state = nil
          shallow_state = -> do

            if line.has_no_content
              take[]

            elsif line.margin_length.zero?
              take[]

            else
              push[]
              p = deep_state
            end
          end

          deep_state = -> do

            if line.has_no_content
              take[]

            elsif line.margin_length.zero?
              frame = _pop line
              p = shallow_state
            else
              take[]
            end
          end

          p = initial_state
          p[]
        end

        st = @_normal_upstream_emission_stream
        begin
          em = st.gets
          em or break
          line = Reflective_Line__.new em
          p.call
          redo
        end while nil

        _finish
      end

      def __parse_regular_tree

        st = @_normal_upstream_emission_stream

        stack = [ frame = Frame__.new( 0, [] ) ]
        @stack = stack

        begin
          em = st.gets
          em or break
          line = Reflective_Line__.new em

          if line.has_no_content
            frame.a.push Amorphous__.new line
            redo
          end

          case frame.margin_length <=> line.margin_length
          when  0
            frame.a.push Amorphous__.new line

          when -1

            frame = Frame__.new line.margin_length, [ Amorphous__.new( line ) ]
            stack.push frame

          when  1

            frame = _pop line

          end

          redo
        end while nil

        _finish
      end

      def _finish

        frame = @stack.pop

        while @stack.length.nonzero?

          frame_ = @stack.pop
          frame_.a.last.accept_children frame.a
          frame = frame_
        end

        Flush___[ frame.a ]
      end

      def _pop line

        begin

          finished_frame = @stack.pop
          possible_parent = @stack.last

          case possible_parent.margin_length <=> line.margin_length
          when 0

            possible_parent.a.last.accept_children finished_frame.a
            possible_parent.a.push Amorphous__.new line

            stop = true
            frame = possible_parent

          when -1

            self._USE_lax_parsing_LOOK

            # BUG - margin will jump back for some help screens (see
            # [#105]-inline-spot-1). the problem is if such a shorter line
            # comes before a longer line then we will incorrectly create a
            # branch there. but how are we to know?

          when 1

            possible_parent.a.last.accept_children finished_frame.a
          end

          stop && break
          redo
        end while nil

        frame
      end
    end

    Frame__ = ::Struct.new :margin_length, :a

    Line_Emission___ = ::Struct.new :string, :stream_symbol

    class Reflective_Line__

      def initialize em

        @stream_symbol = em.stream_symbol
        string = em.string
        @string = string

        md = LINE_RX___.match string

        o = md.offset 1
        @margin_offset = o
        @margin_length = o.last - o.first

        o = md.offset 2
        @has_no_content = o.last == o.first

        @content_range = ::Range.new( * o, true )
      end

      def get_column_A_content
        COL_A_RX___.match( unstyled_header_content )[ 0 ]
      end

      COL_A_RX___ = /\A[^[:space:]]+ (?: [[:space:]] [^[:space:]]+ )* /x

      def unstyled_header_content
        @___uhc ||= __unstyle_header_content
      end

      def __unstyle_header_content
        s = unstyled_content
        d = s.index COLON___
        if d
          s[ 0, d ]
        else
          s
        end
      end

      def unstyled_content
        @___uc ||= Home_::CLI::Styling.unstyle line_content
      end

      def unstyled
        @___unst ||= Home_::CLI::Styling.unstyle @string
      end

      def line_content
        @___lc ||= @string[ @content_range ]
      end

      def blank?
        @has_no_content
      end

      attr_reader(
        :has_no_content,
        :margin_length,
        :stream_symbol,
        :string,
      )
    end

    COLON___ = ':'.freeze

    LINE_RX___ = /\A([ \t]*)([^\n\r]*)\r?\n?\z/

    class Amorphous__

      def initialize x
        @a = nil ; @x = x
      end

      attr_reader :a, :x

      def accept_children a
        @a = a
      end

      def children_count
        if @a
          @a.length
        else
          0
        end
      end
    end

    Flush___ = -> amorph_a do

      nd = if 1 == amorph_a.length
        Monadic_Root_Node__.new
      else
        Root_Node__.new
      end

      nd.children = Recurse__[ amorph_a, nd ]
      nd.freeze
    end

    Recurse__ = -> amorph_a, parent do

      amorph_a.map do | amorph |

        if amorph.children_count.zero?

          Leaf_Node__.new( amorph.x, parent ).freeze

        else

          nd = if 1 == amorph.children_count
            Monadic_Branch_Node__
          else
            Branch_Node__
          end.new amorph.x, parent

          nd.children = Recurse__[ amorph.a, nd ]
          nd.freeze
        end
      end.freeze
    end

    ONLY_CHILD__ = -> do
      @children.first
    end

    class Root_Node__  # has zero or more than one child

      include Parent_Methods__
    end

    class Monadic_Root_Node__ < Root_Node__  # has one child

      define_method :only_child, ONLY_CHILD__

    end

    class Leaf_Node__  # has one parent, no children

      def initialize x, parent
        # @parent = parent
        @x = x
      end

      attr_reader(
        # :parent,
        :x,
      )

      def children_count
        0
      end
    end

    class Branch_Node__ < Leaf_Node__  # has one parent, 2 or more children

      include Parent_Methods__

    end

    class Monadic_Branch_Node__ < Branch_Node__  # has one parent, one child

      define_method :only_child, ONLY_CHILD__
    end

    module Parent_Methods__

      def children_count
        @children.length
      end

      attr_accessor :children
    end

    Is_blank_line_emission__ = -> em do

      # whether or not:
      #
      #   - lines should be capped with an end-of-line sequence
      #   - NIL means "empty line"
      #
      # is something we do not want to be strict about at this late
      # stage in the pipeline.

      s = em.string
      if s
        if s.length.zero?
          TS_._COVER_ME__probably_blank_line_but_where_
        else
          NEWLINE_ == s
        end
      else
        ACHIEVED_
      end
    end

    Magnetics__ = -> do
      CLI::Expect_Section_Magnetics
    end

    EMPTY_P_ = Home_::EMPTY_P_
    Here_ = self
    KEEP_PARSING_ = true
  end
end
