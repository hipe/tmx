module Skylab::Brazen::TestSupport::CLI

  module Expect_Section  # :[#045]. :+[#106]

    # in one go, parse a whole "screen" with indentation-sensitive syntax
    # reminiscent of a super simplified python or OGDL. the result data
    # structure it geared towards assertion.

    class << self

      def tree_via_string s
        tree_via_line_stream__ Home_.lib_.basic::String.line_stream s
      end

      def tree_via_line_stream__ st
        Build___.new( st ).execute
      end
    end  # >>

    class Build___

      def initialize st
        @st = st
      end

      def execute

        st = @st

        stack = [ frame = Frame__.new( 0, [] ) ]
        @stack = stack

        begin
          s = st.gets
          s or break
          line = Line___.new s

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

            frame = __pop line

          end

          redo
        end while nil

        frame = @stack.pop

        while @stack.length.nonzero?

          frame_ = @stack.pop
          frame_.a.last.accept_children frame.a
          frame = frame_
        end

        Flush___[ frame.a ]
      end

      def __pop line

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
            self._DO_ME

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

    class Line___

      def initialize s

        md = LINE_RX___.match s

        o = md.offset 1
        @margin_offset = o
        @margin_length = o.last - o.first

        o = md.offset 2
        @has_no_content = o.last == o.first

        @content_range = ::Range.new( * o, true )

        @line = s
      end

      attr_reader :children, :has_no_content, :line, :margin_length

      def get_column_A_content
        COL_A_RX___.match( unstyled_header_content )[ 0 ]
      end

      COL_A_RX___ = /\A[^[:space:]]+ (?: [[:space:]] [^[:space:]]+ )* /x

      def unstyled_header_content
        @__UHC__ ||= __unstyle_header_content
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
        @__UC__ ||= Home_::CLI::Styling.unstyle line_content
      end

      def line_content
        @line_content ||= @line[ @content_range ]
      end
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

    Parent_Methods__ = ::Module.new

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
        @parent = parent
        @x = x
      end
      attr_reader :parent, :x

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

      attr_accessor :children

      def children_count
        @children.length
      end
    end
  end
end
