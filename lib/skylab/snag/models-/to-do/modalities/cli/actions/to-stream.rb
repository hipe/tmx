module Skylab::Snag

  class Models_::To_Do

    module Actions::Tree

    # <-

    if false  # :#here
    def initialize *a
      @do_pretty, @delegate = a
      @is_valid = true
      @glyphset_i = :wide  # narrow or wide
      @todo_a = []
    end

    attr_reader :is_valid

    attr_writer :glyphset_i

    def if_valid_add_todo_to_tree todo
      collapsed = todo.collapse @delegate
      if collapsed
        @todo_a.push collapsed
      else
        @is_valid = false
      end ; nil
    end

    def render
      rndr = Render__.new @do_pretty, @todo_a, @delegate
      rndr.glyphset_i = @glyphset_i
      rndr.render
    end

    class Render__

      def initialize *a
        @do_pretty, @todo_a, @delegate = a
        @glyphset_i = nil
      end

      attr_writer :glyphset_i

      def render

        @tree = Snag_.lib_.basic::Tree.mutable_node.new
        populate_and_crop_tree
        resolve_producer
        @producer and flush
      end

    private

      def populate_and_crop_tree

        tree = @tree

        @todo_a.each do | todo |

          _path_a = todo.path.split( SEP___ ).push todo.line_number.to_s

          tree.touch_node _path_a, :leaf_node_payload_proc, -> do
            todo
          end
        end

        tree = @tree.any_only_child
        if tree
          @tree = tree  # comment out and see
        end

        NIL_
      end

      SEP___ = ::File::SEPARATOR

      def resolve_producer
        @producer = if @do_pretty
          Build_pretty_tree_lines_producer___[ @tree, @glyphset_i ]
        else
          Build_basic_tree_lines_producer___[ @tree, @glyphset_i ]
        end
      end

      def flush

        begin
          line = @producer.gets
          line or break
          @delegate.receive_payload_line line
          redo
        end while nil

        NEUTRAL_
      end
    end

    class Build_basic_tree_lines_producer___

      Snag_::Model_::Actor[ self,
        :properties, :tree, :glyphset ]

      def initialize( * )
        super
        @glyphset_i ||= :wide  # wide or narrow
      end

      def execute

        st = @tree.to_classified_stream_for :text,
          :glyphset_identifier_x, @glyphset_i

        Callback_::Scn.new do
          card = st.gets
          if card
            line_via_card card
          end
        end
      end

    private

      def line_via_card card
        prefix_s = card.prefix_string
        node = card.node
        s = "#{ prefix_s } #{ node.slug }"
        if node.is_leaf
          a = [ s ]

          todo = node.node_payload
          if todo
            a.push todo.full_source_line
          end
          a * SPACE_
        else
          s
        end
      end
    end

    class Build_pretty_tree_lines_producer___

      Snag_::Model_::Actor[ self,
        :properties, :tree, :glyphset ]

      def initialize( * )
        super
        @glyphset_i ||= :wide  # wide or narrow
        @line_num_style_a = [ :strong, :yellow ].freeze
        @path_style_a = [ :strong, :green ].freeze
        @tag_style_a = [ :reverse, :yellow ].freeze  # #etc
        @fun = -> do
          fun = Snag_.lib_.CLI_lib.pen
          @fun = -> { fun }
          fun
        end
      end

      def execute
        build_cache
        determine_column_A_width
        via_cache_build_stream
      end

    private

      def build_cache

        y = []

        st = @tree.to_classified_stream_for :text,
          :glyphset_identifier_x, @glyphset_i

        card = st.gets
        if card.node.children_count.zero?
          card = nil
        end

        while card

          node = card.node

          _line_node_slug = stylize node.slug,
            node.is_branch ? @path_style_a : @line_num_style_a

          s = "#{ card.prefix_string } #{ _line_node_slug }"
          item = Item__.new s, unstyle( s ).length

          y.push item

          todo = node.node_payload
          if todo
            item.todo = todo
          end

          card = st.gets
        end

        @cache_a = y ; nil
      end

      def determine_column_A_width
        @column_A_width = @cache_a.reduce 0 do |m, item|
          m > item.d ? m : item.d
        end ; nil
      end

      def via_cache_build_stream
        d = -1 ; last = @cache_a.length - 1
        Callback_::Scn.new do
          if d < last
            line_via_item @cache_a.fetch d += 1
          end
        end
      end

      def line_via_item item
        col_a, col_a_w, todo = item.to_a
        col_b = if todo
          "#{ todo.any_pre_tag_string }#{
           }#{ stylize todo.tag_string, @tag_style_a }#{
            }#{ todo.any_post_tag_string }"
        end
        _space = SPACE_ * ( @column_A_width - col_a_w )
        "#{ col_a }#{ _space } |#{ col_b }"
      end

      def stylize s, a
        @fun[].stylify a, s
      end

      def unstyle s
        @fun[].unstyle[ s ]
      end

      Item__ = ::Struct.new :s, :d, :todo
    end
  end
end
