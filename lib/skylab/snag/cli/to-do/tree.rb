module Skylab::Snag

  class CLI::ToDo::Tree
    # [#sl-109] class as namespace
  end

  class CLI::ToDo::Tree::Node

    Snag_._lib.tree.enhance_with_module_methods_and_instance_methods self

    attr_accessor :todo

  end

  class CLI::ToDo::Tree

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
        @tree = CLI::ToDo::Tree::Node.new
        populate_and_crop_tree
        resolve_producer
        @producer and flush
      end

    private

      def populate_and_crop_tree
        @todo_a.each do |todo|
          _a = todo.path.split( SEP__ ).push todo.line_number_string
          @tree.fetch_or_create( :path, _a,
            :init_node, -> nod do
              nod.is_leaf and nod.todo = todo
            end )
        end
        if 1 == @tree.children_count
          @tree = @tree.children.first # comment out and see
        end ; nil
      end

      def resolve_producer
        @producer = if @do_pretty
          Build_pretty_tree_lines_producer__[ @tree, @glyphset_i ]
        else
          Build_basic_tree_lines_producer__[ @tree, @glyphset_i ]
        end
      end

      def flush
        while (( line = @producer.gets ))
          @delegate.receive_payload_line line
        end
        NEUTRAL_
      end

      SEP__ = '/'.freeze
    end

    class Build_basic_tree_lines_producer__

      Snag_::Model_::Actor[ self,
        :properties, :tree, :glyphset ]

      def initialize( * )
        super
        @glyphset_i ||= :wide  # wide or narrow
      end
      def execute
        scn = @tree.get_traversal_scanner :glyphset_x, @glyphset_i
        Callback_::Scn.new do
          card = scn.gets
          card and line_via_card card
        end
      end
    private
      def line_via_card card
        prefix_s = card.prefix[]
        node = card.node
        s = "#{ prefix_s } #{ node.slug }"
        if node.is_leaf
          a = [ s ]
          if node.todo
            a.push node.todo.full_source_line
          end
          a * SPACE_
        else
          s
        end
      end
    end

    class Build_pretty_tree_lines_producer__

      Snag_::Model_::Actor[ self,
        :properties, :tree, :glyphset ]

      def initialize( * )
        super
        @glyphset_i ||= :wide  # wide or narrow
        @line_num_style_a = [ :strong, :yellow ].freeze
        @path_style_a = [ :strong, :green ].freeze
        @tag_style_a = [ :reverse, :yellow ].freeze  # #etc
        @fun = -> do
          fun = Snag_._lib.CLI_lib.pen
          @fun = -> { fun }
          fun
        end
      end

      def execute
        build_cache
        determine_column_A_width
        via_cache_build_scanner
      end

    private

      def build_cache
        scn = @tree.get_traversal_scanner :glyphset_x, @glyphset_i ; y = []
        card = scn.gets
        if card.node.children_count.zero?
          card = nil
        end
        while card
          node = card.node
          _line_node_slug = stylize node.slug,
            node.is_branch ? @path_style_a : @line_num_style_a
          s = "#{ card.prefix[] } #{ _line_node_slug }"
          item = Item__.new s, unstyle( s ).length
          y.push item
          if node.is_leaf && node.todo
            item.todo = node.todo
          end
          card = scn.gets
        end
        @cache_a = y ; nil
      end

      def determine_column_A_width
        @column_A_width = @cache_a.reduce 0 do |m, item|
          m > item.d ? m : item.d
        end ; nil
      end

      def via_cache_build_scanner
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
