module Skylab::Basic

  module Tree

    class Magnetics::Tree_via_IndentedLineStream  # :[#043].

      Attributes_actor_.call( self,
        :upstream_x,
        :build_using,
        :glyph,
      )

      include Simple_Selective_Sender_Methods_

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      def execute

        @build_using ||= -> _, * do _ end
        @glyph_regex = /\A([[:space:]]*)#{ ::Regexp.escape @glyph }/

        ok, has = pair_for_next_frame
        ok and ( via_first_frame if has )
      end

      def via_first_frame
        agent = self
        @stack = [ @frame ]
        ok = nil
        node = Here_::ImmutableNode.new do
          cx_a = []
          ok = agent.add_current_and_each_sibling_or_child self do |x|
            cx_a.push x
          end
          if ok
            @children = cx_a.freeze
            @children_count = cx_a.length
          end
        end
        ok && node
      end

      def add_current_and_each_sibling_or_child parent, & child_p
        agent = self
        current_frame = @frame
        ok, has = pair_for_next_frame
        while ok
          next_node_is_child = next_node_is_sibling = next_node_is_above = nil
          if has
            next_frame = @frame
            case current_frame.indent_d <=> next_frame.indent_d
            when -1
              ok = validate_new_indent current_frame
              ok or break
              next_node_is_child = true
            when 0
              ok = validate_new_indent current_frame
              ok or break
              next_node_is_sibling = true
            when 1
              next_node_is_above = true
              ok = reduce_stack
              ok or break
            end
          end

          ok, val_x = value_pair_via_content_string_and_parent(
            current_frame.content_s, parent )
          ok or break

          node = Here_::ImmutableNode.new do
            @parent = parent
            @value = val_x
            if next_node_is_child
              cx_a = []
              agent.push_stack_frame next_frame
              ok = agent.add_current_and_each_sibling_or_child self do |x|
                cx_a.push x
              end
              ok or break
              agent.pop_stack_frame
            end
            if cx_a
              @children = cx_a.freeze
              @children_count = cx_a.length
            else
              @children_count = 0
            end
          end
          ok or break
          child_p[ node ]
          if next_node_is_child  # next node *was* child, so we descended.
            if @frame  # the child call frame left this behind

              if current_frame.indent_d == @frame.indent_d

                # the frame that the call frame is on is sibling to this
                # dangling frame. make this frame that frame and procede.

                current_frame = @frame
                ok, has = pair_for_next_frame

              else
                # assume this is a child node of one of our parent nodes,
                # i.e an aunt node or whatever. let the call frame return
                # and try again until the above takes.
                break
              end
            else
              break  # assume child call frame consumed last node
            end
          elsif next_node_is_sibling
            current_frame = next_frame
            ok, has = pair_for_next_frame
          elsif next_node_is_above
            break
          else
            break  # assume no next node
          end
        end
        ok
      end

      def value_pair_via_content_string_and_parent s, parent
        ok = true
        x = @build_using.call s, parent do | i, * i_a, & ev_p |
          if :error == i
            ok = false
          end
          @on_event_selectively.call i, * i_a, & ev_p
        end
        [ ok, x ]
      end

      def push_stack_frame x
        @stack.push x
        nil
      end

      def pop_stack_frame
        @stack.pop
        nil
      end

      def validate_new_indent current_frame
        _excerpt = @frame.indent_s[ 0, current_frame.indent_s.length ]
        if _excerpt == current_frame.indent_s
          ACHIEVED_
        else
          maybe_send_event :error, :whitespace_mismatch do
            build_not_OK_event_with :whitespace_mismatch,
                :previous_whitespace, current_frame.indent_s,
                :current_whitespace, @frame.indent_s do |y, o|
              y << "whitespace mismatch"
            end
          end
          UNABLE_
        end
      end

      def reduce_stack  # assume top of stack is deeper than current frame
        @stack.pop
        ok = true
        begin
          if @stack.length.zero?
            maybe_send_event :error, :invalid_dedent do
              build_not_OK_event_with :invalid_dedent
            end
            ok = false
            break
          end
        end while nil
        ok
      end

      def pair_for_next_frame
        if re_init_next_line
          via_line_pair_for_next_frame
        else
          @frame = nil
          [ ACHIEVED_, false ]
        end
      end

      def re_init_next_line
        @line = @upstream_x.gets
        @line ? true : false
      end

      def via_line_pair_for_next_frame
        md = @glyph_regex.match @line
        if md
          @frame = Frame__.new md[ 1 ], md[ 1 ].length, md.post_match
          [ ACHIEVED_, true ]
        else
          @frame = false
          maybe_send_event :error do
            bld_line_parse_error
          end
          [ UNABLE_, false ]
        end
      end

      attr_reader :frame

      def bld_line_parse_error
        build_not_OK_event_with :line_does_not_have_glyph,
            :line, @line, :glyph, @glyph do |y, o|
          y << "line does not have glyph #{ ick o.glyph }: #{ ick o.line }"
        end
      end

      Frame__ = ::Struct.new :indent_s, :indent_d, :content_s

    end
  end
end
