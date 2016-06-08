module Skylab::Treemap

  class Models_::Node

    # for both efficency of memory usage and our own mental sanity (along one
    # axis), we are experimentally cramming lots of concerns from different
    # levels of abstraction into this one class. (at one point we called it
    # "God_Node".) it starts out as a line and ends up as a tree node. the
    # appropriate parts of this should get moved down to the appropriate
    # input adapters when it is abstraction time.

    RX___ = /\A
      (?<indent> [ \t]* )
      (?<content> [^\r\n]* )
      (?<terminator> \r?\n )?
    \z/x

    def initialize line_s, lineno

      @indent, @content, @terminator = RX___.match( line_s ).captures
      @lineno = lineno
    end

    COLON___ = ':'

    def indent_length
      @indent.length
    end

    def has_content
      @content.length.nonzero?
    end

    def is_blank
      @content.length.zero?
    end

    attr_reader :content, :indent, :lineno, :terminator

    def is_root
      false  # this class is never used for the root node.
    end

    # ~ mutation phase: is branch or leaf


    def receive_is_branch branch_identifier_d

      extend Branch_Methods

      @_branch_number = branch_identifier_d
      NIL_
    end

    module Branch_Methods

      def description_for_branch
        "        >>>> ( branch #{ @_branch_number }: #{
          }#{ content_for_description_ } )"
      end

      def branch_number
        @_branch_number
      end

      def is_leaf
        false
      end

      def is_branch
        true
      end
    end

    def content_for_description_
      @content
    end

    def receive_is_leaf

      extend Leaf_Methods___
      NIL_
    end

    module Leaf_Methods___

      def description_for_leaf_under_etc etc

        st = to_parent_stream_around etc

        s_a = []
        st.each do | x |
          s_a.push "(#{ x.branch_number }) "
        end
        s_a.reverse!

        s_a.length == @_depth_index or self._SANITY

        "#{ s_a * EMPTY_S_ }#{ @content }"
      end

      def is_leaf
        true
      end

      def is_branch
        false
      end
    end

    # ~ mutation phase: who is my parent?

    def to_parent_stream_around branch_a

      current = self

      Common_.stream do

        if current.is_not_root

          parent = branch_a.fetch current.parent_branch_number
          current = parent
          parent
        end
      end
    end

    def receive_parent_branch_number d, my_depth_index

      define_singleton_method :depth_index, DEPTH_INDEX_METHOD___
      define_singleton_method :parent_branch_number, PARENT_METHOD___

      @_depth_index = my_depth_index
      @_parent_branch_number = d

      NIL_
    end

    DEPTH_INDEX_METHOD___ = -> do
      @_depth_index
    end

    PARENT_METHOD___ = -> do
      @_parent_branch_number
    end

    def is_not_root
      true
    end

    Actions = nil
  end
end
