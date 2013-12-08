module Skylab::Snag

  class CLI::ToDo::Tree
    # [#sl-109] class as namespace
  end

  class CLI::ToDo::Tree::Node

    extend  Porcelain::Tree::ModuleMethods

    include Porcelain::Tree::InstanceMethods

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
      ea = ::Enumerator.new do |y|
        trav = Porcelain::Tree::Traversal.new
        trav.traverse tree do |card|
          prefix = trav.prefix card
          if (( n = card.node )).is_leaf
            a = [ "#{ prefix } #{ n.slug }" ]
            if n.todo
              a << n.todo.full_source_line
            end
            y << a.join( ' ' )
          else
            y << "#{ prefix } #{ n.slug }"
          end
        end
      end
      Headless::Services::Producer.new ea
    end

    fun = Headless::CLI::Pen::FUN
    line_num_style_a = [ :strong, :yellow ]
    path_style_a = [ :strong, :green ]
    tag_style_a = [ :reverse, :yellow ]

    tree_lines_producer_pretty = -> tree do
      stylize = fun.stylize # here is where you could un-color it if not tty

      scn = tree.get_traversal_scanner :glyphset_x, :wide  # :narrow too

      cache_a = [ ]
      while (( card = scn.gets ))
        n = card.node
        if n.is_branch
          line_node_slug = stylize[ n.slug, * path_style_a ]
        else
          line_node_slug = stylize[ n.slug, * line_num_style_a ]
        end
        cache_a << (( ro = ["#{ card.prefix[] } #{ line_node_slug }" ] ))
        ro << fun.unstyle[ ro[0] ].length
        if n.is_leaf && n.todo
          ro << n.todo
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
      tree = CLI::ToDo::Tree::Node.new
      @todos.each do |todo|
        tree.fetch_or_create(
          :path, ( todo.path.split( '/' ) << todo.line_number_string ),
          :init_node, -> nod do nod.is_leaf and nod.todo = todo end )
      end

      if 1 == tree.children_count
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

  private

    def initialize client, do_pretty
      @do_pretty = do_pretty
      @todos = []
      super client
    end
  end
end
