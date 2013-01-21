module Skylab::Snag
  class CLI::ToDo::Tree
    # [#sl-109] class as namespace
  end

  class CLI::ToDo::Tree::Node < Porcelain::Tree::Node
    attr_accessor :todo
  end

  class CLI::ToDo::Tree
    include Snag::Core::SubClient::InstanceMethods

    def << todo
      if todo.valid?
        @todos.push todo.collapse
      end
      nil
    end

    tree_lines_producer_basic = -> tree do
      lines = Porcelain::Tree.lines tree, node_formatter: -> x { x }
      enum = ::Enumerator.new do |y|
        lines.each do |line|
          if line.node.is_leaf
            a = [ "#{ line.prefix } #{ line.node.slug }" ]
            if line.node.todo
              a.push line.node.todo.full_source_line
            end
            y << a.join( ' ' )
          else
            y << "#{ line.prefix } #{ line.node.slug }"
          end
        end
        nil
      end
      Headless::Services::Producer.new enum
    end

    fun = Headless::CLI::Pen::FUN
    line_num_style_a = [ :strong, :yellow ]
    path_style_a = [ :strong, :green ]
    tag_style_a = [ :reverse, :yellow ]

    tree_lines_producer_pretty = -> tree do
      stylize = fun.stylize # here is where you could un-color it if not tty
      lines = Porcelain::Tree.lines tree,
        glyph_set: :wide, # :narrow is fine too ..
        node_formatter: -> x { x }

      cache_a = [ ]
      lines.each do |line|
        if line.node.is_branch
          line_node_slug = stylize[ line.node.slug, * path_style_a ]
        else
          line_node_slug = stylize[ line.node.slug, * line_num_style_a ]
        end
        cache_a << ( row = ["#{ line.prefix } #{ line_node_slug }" ] )
        row << fun.unstylize[ row[0] ].length
        if line.node.is_leaf && line.node.todo
          row << line.node.todo
        end
      end
      col_a_width = cache_a.reduce( 0 ) do |m, row|
        m > row[1] ? m : row[1]
      end
      Headless::Services::Producer.new( ::Enumerator.new do |y|
        cache_a.each do | col_a, col_a_w, todo |
          col_b = if todo
            "#{ todo.pre_tag_string }#{
              }#{ stylize[ todo.tag_string, * tag_style_a ] }#{
              }#{ todo.post_tag_string }"
          end
          y << "#{ col_a }#{ ' ' * ( col_a_width - col_a_w ) }#{
            } |#{ col_b }"
        end
      end )
    end

    define_method :render do
      _root = CLI::ToDo::Tree::Node.new slug: :root
      tree = @todos.reduce _root do |node, todo|
        path_a = todo.path.split( '/' ).push todo.line_number_string
        node.find! path_a do |nd|
          if nd.is_leaf
            nd.todo = todo
          end
        end
        node
      end

      if 1 == tree.children_length
        tree = tree.children.first # comment out and see
      end

      if @do_pretty
        producer = tree_lines_producer_pretty[ tree ]
      else
        producer = instance_exec tree, &tree_lines_producer_basic
      end
      if producer
        line = nil
        payload( line ) while line = producer.gets
      end
    end

  protected

    def initialize client, do_pretty
      _snag_sub_client_init! client
      @do_pretty = do_pretty
      @todos = []
    end
  end
end
