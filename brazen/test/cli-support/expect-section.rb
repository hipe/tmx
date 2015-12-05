module Skylab::Brazen::TestSupport

  module CLI_Support::Expect_Section  # :[#045]. :+[#106]

    # in one go, parse a whole "screen" with indentation-sensitive syntax
    # reminiscent of a super simplified python or OGDL. the result data
    # structure is geared towards assertion.

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

    # -- (forward declarations)

    Leaf_Node__ = ::Class.new
    Branch_Node__ = ::Class.new Leaf_Node__

    # -- conversion methods

    class Branch_Node__

      def to_body_string m

        st = _to_full_pre_order_stream
        st.gets
        st.reduce_into_by "" do | memo, node |
          memo << node.x.send( m )
        end
      end

      def to_string m

        _to_full_pre_order_stream.reduce_into_by "" do | memo, node |
          memo << node.x.send( m )
        end
      end

      def to_emission_stream  # assume not called on root

        _to_full_pre_order_stream.map_by do | node |
          node.x  # our native emission structure, that looks like a "Line" structure
        end
      end
    end

    class Leaf_Node__

      def to_emission_stream

        Callback_::Stream.via_item @x
      end
    end

    # -- traversal methods

    class Leaf_Node__

      def _to_full_pre_order_stream
        Callback_::Stream.via_item self
      end
    end

    module Parent_Methods__

      def to_pre_order_stream_
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

        Callback_.stream do
          p[]
        end
      end

      def ___to_child_stream
        Callback_::Stream.via_nonsparse_array @children
      end
    end

    # --

    class Help_Screen_State

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

        st = Callback_::Polymorphic_Stream.via_array x_a
        @polymorphic_upstream_ = st
        begin
          _m = st.gets_one
          _kp = send :"#{ _m }="
          _kp or fail
        end until st.no_unparsed_exists
        remove_instance_variable :@polymorphic_upstream_
        NIL_  # ..
      end

      def lax_parsing=
        @_build.become_lax
        KEEP_PARSING_
      end

      def state=
        state = @polymorphic_upstream_.gets_one
        @exitstatus = state.exitstatus
        @_build.emission_array = state.lines
        KEEP_PARSING_
      end

      def stream=
        @_build.stream_symbol = @polymorphic_upstream_.gets_one
        KEEP_PARSING_
      end

      def string=
        @_build.one_big_string = @polymorphic_upstream_.gets_one
        KEEP_PARSING_
      end

      def _build_tree
        build = remove_instance_variable :@_build
        @tree = build.execute
        @stream_set = build.stream_set
        NIL_
      end

      def __index_section_titles

        bx = Callback_::Box.new

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
        _em_st = Callback_::Stream.via_nonsparse_array a
        _receive_upstream_emission_stream _em_st
        a
      end

      def one_big_string= s

        scn = Home_.lib_.basic::String.line_stream s

        _em_st = Callback_.stream do

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

        _my_st = Callback_.stream do
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
        @___uc ||= Home_::CLI_Support::Styling.unstyle line_content
      end

      def unstyled
        @___unst ||= Home_::CLI_Support::Styling.unstyle @string
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

    EMPTY_P_ = Home_::EMPTY_P_
    Here_ = self
    KEEP_PARSING_ = true
  end
end
