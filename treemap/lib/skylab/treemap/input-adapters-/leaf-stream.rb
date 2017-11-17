module Skylab::Treemap

  class Input_Adapters_::Leaf_Stream  # full pseudocode at [#002]

    class << self

      def call o_st, & p

        new( o_st, & p ).execute
      end

      def required_stream
        :indented_line_normalizer
      end
    end  # >>

    def initialize o_st, & p
      @o_st = o_st
      @_listener = p
    end

    def execute

      branch_cache_a = nil
      main_loop = main_p = nil
      o_st = @o_st
      o = previous_o = nil

      p = -> do

        o = o_st.gets

        if o
          p = main_p

          branch_cache_a = []

          @_listener.call :info, :data, :branch_cache_array do
            branch_cache_a
          end

          previous_o = Root___.new
          main_loop[]
        end
      end

      end_of_input = nil

      main_p = -> do
        o = o_st.gets
        if o
          main_loop[]
        else
          end_of_input[]
        end
      end

      do_redo = x = nil
      deeper = same = shallower = nil

      main_loop = -> do   # assume previous_o and o

        begin

          _prev_indent = previous_o.indent_length
          _my_indent = o.indent_length

          case _prev_indent <=> _my_indent
          when 0
            same[]
          when -1
            deeper[]
          when 1
            shallower[]
          end
          if do_redo
            o = o_st.gets
            if o
              redo
            end
            end_of_input[]
          end
          break
        end while nil
        x
      end

      same = -> do

        previous_o.receive_is_leaf
        sibling = previous_o

        o.receive_parent_branch_number(
          sibling.parent_branch_number,
          sibling.depth_index )

        x = previous_o
        previous_o = o
        o = nil
        do_redo = false  #  we found a leaf
        NIL_
      end

      deeper = -> do

        d = branch_cache_a.length

        branch_cache_a[ d ] = previous_o

        previous_o.receive_is_branch d

        o.receive_parent_branch_number d, previous_o.depth_index + 1

        x = nil
        previous_o = o
        o = nil
        do_redo = true  # we haven't determined a leaf yet
        NIL_
      end

      shallower = -> do

        previous_o.receive_is_leaf

        st = previous_o.to_parent_stream_around branch_cache_a

        my_indent_length = o.indent_length
        begin

          prnt = st.gets
          case prnt.indent_length <=> my_indent_length

          when -1

            do_redo = false
            p = EMPTY_P_
            x = UNABLE_
            self.__TODO_when_indentation_syntax_error o, prnt
            break

          when 0

            found = true
            sibling = prnt
            break

          when 1
            redo
          end
        end while nil

        if found

          o.receive_parent_branch_number(
            sibling.parent_branch_number,
            sibling.depth_index )

          x = previous_o
          previous_o = o
          o = nil
          do_redo = false  # because we determined a leaf here
        end

        NIL_
      end

      end_of_input = -> do

        if previous_o

          previous_o.receive_is_leaf
          x = previous_o
          previous_o = nil
          do_redo = false

        else
          NIL_
        end
      end

      Common_::MinimalStream.by do
        p[]
      end
    end

    class Root___

      def indent_length
        -1
      end

      def depth_index
        0
      end

      def receive_is_branch d

        d.zero? or self._SANITY
        extend Home_::Models::Node::Legacy::Branch_Methods
        @_branch_number = d
        NIL_
      end

      def content_for_description_
        '[artificial root node]'
      end

      def is_not_root
        false
      end
    end
  end
end
