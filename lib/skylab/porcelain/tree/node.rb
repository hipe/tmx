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
        children[child.slug] = child # let child choose its own slug
      end
      if 0 == path_arr.length
        child
      else
        child._find path_arr, create, &b
      end
    end
    def longest_common_base_path
      [(lone = children.first).slug] + (lone.longest_common_base_path || []) if 1 == children_length
    end
    def merge! other, opts=nil
      ks = other.keys ; except = nil
      opts and opts.each do |k ,v|
        case k
        when :except ; ks -= opts[:except]
        else raise ArgumentError.new("no. #{k}")
        end
      end
      ks.zip(other.values_at(* ks)).each do |k, val|
        if self.key? k
          case val
          when TrueClass, FalseClass
            self[k] == other[k] or fail("merge conflict on #{k.inspect}")
          when String, Symbol
            self[k].kind_of?(Array) or self[k] = [self[k]]
            self[k] |= [val]
          when Array
            self[k].kind_of?(Array) or self[k] = [self[k]]
            self[k] |= val
          else
            fail("implement me -- merge for #{val.class}")
          end
        else
          self[k] = case val
                    when FalseClass, TrueClass, NilClass, Symbol ; val
                    else val.dup
                    end
        end
      end
      self
    end
    def _paths arr, prefix
      if ! root? || prefix
        my_path = [prefix, slug, ('' if children?)].compact.join(path_separator)
        arr.push(my_path)
      end
      if children?
        my_prefix = root? ? nil : [prefix, slug].compact.join(path_separator)
        children.each { |node| node._paths(arr, my_prefix) }
      end
      nil
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
  class Tree::Children < Array
    alias_method :array_fetch, :[]
    def [] key
      key.kind_of?(Integer) and return array_fetch(key)
      @keys.key?(key) or return nil
      array_fetch(@keys[key])
    end
    alias_method :array_put, :[]=
    def []= key, val
      key.kind_of?(Integer) and return array_put(key, val)
      if @keys[key]
        overwrite = true
        old_val = array_fetch(@keys[key])
        at_index = @keys[key]
      else
        at_index = (@keys[key] = length)
        overwrite = false
      end
      if overwrite and old_val.respond_to?(:aliases?) and old_val.aliases?
        old_val.aliases.each { |aliaz| @keys.delete(aliaz) }
      end
      if val.respond_to?(:aliases?) and val.aliases?
        val.aliases.each { |aliaz| @keys[aliaz] = at_index }
      end
      array_put(at_index, val)
    end
    def initialize
      @keys = {}
    end
    attr_reader :keys
  end
  module Tree::Node::ModuleMethods
    include Tree::Node::CommonMethods
    def build *a, &b
      new(*a, &b)
    end
    def combine nodes, lambdii=nil
      lambdii ||= { slugmaker: ->(n) { n.slug } }
      slugmaker = lambdii[:slugmaker] or fail("slugmaker lambda is required")
      # map each node with its key, in both a hash and an array
      array = nodes.map { |node| [slugmaker.call(node), node] }
      # map each key with an array of indexes into the above array
      hash = Hash.new { |h, k| h[k] = [] }
      array.each_with_index { |arr, idx| hash[arr.first].push idx }
      # if the hash is a size 1 then all nodes at this level are a match (per slugmaker)
      case hash.size
      when 0
        nil
      when 1
        combined = array.reduce(build(root: true)) { |m, n| m.merge!(n[1], :except => [:children] ) }
        order = []
        childs_by_name = array.reduce(Hash.new { |h, k| order.push(k) ; h[k] = [] }) do |m, n|
          n[1].children? and n[1].children.each { |c| m[slugmaker.call(c)].push c } ; m
        end
        order.any? and order.reduce(combined.children) do |m, slug|
          m[slug] = (1 == (childs = childs_by_name[slug]).size) ? childs.first : combine(childs, lambdii)
          m
        end
        combined
      else
        fail("implement me!")
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
    extend Tree::Node::ModuleMethods
    include Tree::Node::InstanceMethods
    def initialize hash=nil
      hash and hash.each { |k, v| self[k] = v }
      block_given? and yield(self)
    end
    def children
      self[:children] ||= Tree::Children.new
    end
    def children_length
      self[:children] ? self[:children].length : 0
    end
    def root?
      self[:root] # ! self[:slug]
    end
    def slug
      self[:slug] or fail(':slug not set')
    end
  end
end
