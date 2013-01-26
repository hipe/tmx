module Skylab::Porcelain
  class Tree::Node
    # [#sl-109] class as namespace
  end

  module Tree::Node::CommonMethods
    def path_separator
      Tree::DEFAULT_PATH_SEPARATOR
    end
  end

  module Tree::Node::InstanceMethods
    include Tree::Node::CommonMethods

    def has_children
      0 < children_length
    end

    def children_length          # can be redefined e.g.
      children.length            # to avoid autovivification
    end

    def find path, &init_new_node_block
      _find _find_path_normalize( path ), false, &init_new_node_block
    end

    def find! path, &init_new_node_block
      _find _find_path_normalize( path ), true, &init_new_node_block
    end

    def is_branch
      ! is_leaf
    end

    def is_leaf
      0 == children_length
    end

    attr_accessor :is_root

    def isomorphic_slugs_length   # can be redefined e.g.
      isomorphic_slugs.length     # to avoid autovivification
    end

    def longest_common_base_path
      res = nil
      if 1 == children_length
        res = [ children.first.slug ]
        r = children.first.longest_common_base_path
        res.concat r if r
      end
      res
    end

    def merge! other, opt_h=nil
      attrs = other.merge_attributes
      if opt_h then -> do
        h = { except: -> v { attrs -= v } }
        opt_h.each { |k, v| h.fetch( k )[ v ] }
        opt_h = nil
      end.call end
      attrs.each do |attr|        # (this looks somewhat like [#mh-014])
        new  = nil
        mine = send attr
        othr = other.send attr
        if mine.nil?
          new = case othr
                when ::FalseClass, ::TrueClass, ::NilClass, ::Symbol ; othr
                else othr.dup
                end
        else
          case othr
          when ::NilClass # rien
          when ::TrueClass, ::FalseClass
            if mine != othr
              fail "merge conflict on #{ attr.inspect } #{
                }(#{ mine.inspect } vs. #{ othr.inspect })"
            end
          when ::String, ::Symbol, ::Array
            _m = ::Array === mine ? mine : ( new = [mine] )
            _v = ::Array === othr ? othr : [othr]
            _m.concat( _v - _m ) # yes
          else
            fail "implement merge for #{ othr.class }"
          end
        end
        if ! new.nil?
          send "#{ attr }=", new
        end
      end
      self
    end

    def slug
      0 < isomorphic_slugs_length or fail "slug not set"
      isomorphic_slugs.first
    end

    def slug= slug
      0 == isomorphic_slugs_length or fail "won't clobber slug"
      isomorphic_slugs[0] = slug
    end

    def text opts={}, &block
      opts = { node_formatter: :slug }.merge opts
      Tree.text self, opts, &block
    end

    def to_paths
      _paths( arr=[], nil )
      arr
    end

  protected

    param_h_h = {
      is_root: -> v { self.is_root = v },
      slug:    -> v { self.slug = v }
    }

    define_method :initialize do |param_h, &b|
      super( & nil )
      param_h.each do |k, v|
        instance_exec v, & param_h_h.fetch( k )
      end
      b[ self ] if b
    end

    def _find_path_normalize mixed
      if ::Array === mixed
        mixed.dup
      else
        mixed.to_s.split path_separator
      end
    end

    def _find path_a, do_create, &b
      res = nil
      begin
        if path_a.length.zero?
          break( res = self )
        end
        slug = path_a.shift
        slug = slug.to_s if ::Integer === slug # else hell breaks actually loose
        child = children[ slug ]
        if ! child
          break if ! do_create
          child = self.class.build slug: slug, &b # @add_parent
          children.set(* child.isomorphic_slugs, child )
        end
        if path_a.length.zero?
          res = child
        else
          res = child._find path_a, do_create, &b
        end
      end while nil
      res
    end

    def _paths arr, prefix
      if ! is_root || prefix # @todo wtf
        my_path = [prefix, slug, ('' if has_children)].compact.join(path_separator)
        arr.push(my_path)
      end
      if has_children
        my_prefix = is_root ? nil : [prefix, slug].compact.join(path_separator)
        children.each { |node| node._paths(arr, my_prefix) }
      end
      nil
    end
  end

  module Tree::Node::ModuleMethods
    include Tree::Node::CommonMethods

    def build *a, &b
      new( *a, &b )
    end

    def combine node1, node2, *nodes, &slugmaker
      nodes[0, 0] = [ node1, node2 ]
      slugmaker ||= -> n { n.slug }
      pairs = nodes.map { |n| [ slugmaker[ n ], n ] } # pairs of [slug, node]
      slug_h = ::Hash.new { |h, k| h[k] = [] } # map each slug to
                                  # a list of indices into `arr`
      pairs.each_with_index do |pair, idx|
        slug_h[ pair.first ].push idx
      end

      res = nil
      case slug_h.length
      when 0 # res stays as nil
      when 1 # when `slug_h` is length 1 then associate all nodes at this level
        combined = pairs.reduce( build is_root: true ) do |m, p|
          m.merge! p.last, except: [:children]
        end
        order_a = []
        _h = ::Hash.new { |h, k| order_a << k ; h[k] = [] }
        childs_by_slug = pairs.reduce _h do |m, p|
          if p.last.has_children
            p.last.children.each do |c|
              m[ slugmaker[ c ] ] << c
            end
          end
          m
        end
        if order_a.length.nonzero?
          order_a.reduce combined.children do |m, slug|
            childs = childs_by_slug[ slug ]
            if 1 == childs.length
              m[slug] = childs.first
            else
              m[slug] = combine( *childs, &slugmaker )
            end
            m
          end
        end
        res = combined
      else
        fail "do you really want to combine trees that #{
          }don't have isomorphic root nodes? #{
          }(#{ slug_h.keys.map(& :inspect ).join ', ' })"
      end
      res
    end

    def from_paths paths, &node_init_block
      sep = path_separator
      paths.reduce(build( is_root: true, &node_init_block)) do |root, path|
        root.find!(path.to_s.split(sep), &node_init_block)
        root
      end
    end
  end

  class Tree::Node
    extend  Tree::Node::ModuleMethods
    include Tree::Node::InstanceMethods

    attr_reader :children

    alias_method :children_ivar, :children

    def children
      children_ivar or @children = Tree::Children.new
    end

    def children_length
      children_ivar ? @children.length : 0
    end

    attr_reader :isomorphic_slugs

    alias_method :isomorphic_slugs_ivar, :isomorphic_slugs

    def isomorphic_slugs
      @isomorphic_slugs ||= []
    end

    def isomorphic_slugs_length
      isomorphic_slugs_ivar ? @isomorphic_slugs.length : 0
    end
  end
end
