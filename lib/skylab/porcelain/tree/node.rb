module Skylab::Porcelain
  class Tree::Node < Hash
    # shenanigans
  end
  module Tree::Node::CommonMethods
    def path_separator
      Tree::DEFAULT_PATH_SEPARATOR
    end
  end
  module Tree::Node::InstanceMethods
    include Tree::Node::CommonMethods
    def children?
      0 < children_length
    end
    def children_length # children may want to override to avoid autovivification
      children.length
    end
    def find path, &init_new_node_block
      _find _find_path_normalize(path), false, &init_new_node_block
    end
    def find! path, &init_new_node_block
      _find _find_path_normalize(path), true, &init_new_node_block
    end
    def _find_path_normalize mixed
      ::Array === mixed ? mixed.dup : mixed.to_s.split(path_separator)
    end
    def _find path_arr, create, &b
      path_arr.empty? and return self
      slug = path_arr.shift
      if slug.kind_of?(Integer) # hell breaks loose
        slug = slug.to_s
      end
      child = children[slug]
      if ! child
        create or return nil
        child = self.class.build(slug: slug, &b) # @add_parent
        children.set(* child.isomorphic_slugs, child)
      end
      if 0 == path_arr.length
        child
      else
        child._find path_arr, create, &b
      end
    end
    def initialize params, &b
      params.each { |k, v| send("#{k}=", v) }
      block_given? and yield(self)
    end
    def isomorphic_slugs_length # children may want to override to avoid autovivification
      isomorphic_slugs.length
    end
    def leaf?
      0 == children_length
    end
    def longest_common_base_path
      [(lone = children.first).slug] + (lone.longest_common_base_path || []) if 1 == children_length
    end
    def merge! other, opts=nil
      attrs = other.merge_attributes
      opts and { except: ->(v) { attrs -= v } }.tap { |h| opts.each { |k, v| h[k].call(v) } }
      attrs.each do |attr|
        mine = send(attr) ; othr = other.send(attr) ; new = nil
        if mine.nil?
          new = case othr
                when FalseClass, TrueClass, NilClass, Symbol ; othr
                else othr.dup
                end
        else
          case othr
          when NilClass # rien
          when TrueClass, FalseClass
            mine == othr or fail("merge conflict on #{attr.inspect} (#{mine.inspect} vs. #{othr.inspect})")
          when String, Symbol, Array
            _m = Array === mine ? mine : (new = [mine])
            _v = Array === othr ? othr : [othr]
            _m.concat(_v - _m) # yes
          else
            fail("implement merge for #{othr.class}")
          end
        end
        new.nil? or send("#{attr}=", new)
      end
      self
    end
    def _paths arr, prefix
      if ! root? || prefix # @todo wtf
        my_path = [prefix, slug, ('' if children?)].compact.join(path_separator)
        arr.push(my_path)
      end
      if children?
        my_prefix = root? ? nil : [prefix, slug].compact.join(path_separator)
        children.each { |node| node._paths(arr, my_prefix) }
      end
      nil
    end
    def slug
      0 < isomorphic_slugs_length or fail("slug not set")
      isomorphic_slugs.first
    end
    def slug= slug
      0 == isomorphic_slugs_length or fail("won't clobber slug")
      isomorphic_slugs[0] = slug
    end
    def text opts={}, &block
      opts = { node_formatter: :slug }.merge opts
      Tree.text(self, opts, &block)
    end
    def to_paths
      _paths(arr=[], nil)
      arr
    end
  end
  module Tree::Node::ModuleMethods
    include Tree::Node::CommonMethods
    def build *a, &b
      new(*a, &b)
    end
    def combine node1, node2, *nodes, &slugmaker
      nodes[0, 0] = [node1, node2]
      slugmaker ||= ->(n) { n.slug }
      pairs = nodes.map { |n| [slugmaker.call(n), n] } # pairs of [slug, node]
      slugs = Hash.new { |h, k| h[k] = [] } # map each slug to a list of indices into `arr`
      pairs.each_with_index { |pair, idx| slugs[pair.first].push idx }
      case slugs.size
      when 0 ; nil
      when 1 # when `slugs` is length 1 then associate all nodes at this level
        combined = pairs.reduce(build(root: true)) { |m, p| m.merge!(p.last, :except => [:children] ) }
        order = []
        childs_by_slug = pairs.reduce(Hash.new { |h, k| order.push(k) ; h[k] = [] }) do |m, p|
          p.last.children? and p.last.children.each { |c| m[slugmaker.call(c)].push c } ; m
        end
        order.any? and order.reduce(combined.children) do |m, slug|
          m[slug] = (1 == (childs = childs_by_slug[slug]).size) ? childs.first : combine(*childs, &slugmaker) ; m
        end
        combined
      else
        fail("do you really want to combine trees that don't have isomorphic root nodes? " <<
               "(#{slugs.keys.map(&:inspect).join(', ')})")
      end
    end
    def from_paths paths, &node_init_block
      sep = path_separator
      paths.reduce(build(root: true, &node_init_block)) do |root, path|
        root.find!(path.to_s.split(sep), &node_init_block)
        root
      end
    end
  end
  class Tree::Node
    extend  Tree::Node::ModuleMethods
    include Tree::Node::InstanceMethods
    def children
      self[:children] ||= Tree::Children.new
    end
    def children_length
      self[:children] ? self[:children].length : 0
    end
    def isomorphic_slugs
      self[:isomorphic_slugs] ||= []
    end
    def isomorphic_slugs_length
      self[:isomorphic_slugs] ? self[:isomorphic_slugs].length : 0
    end
    def root= b
      self[:root] = b
    end
    def root?
      self[:root]
    end
  end
end
