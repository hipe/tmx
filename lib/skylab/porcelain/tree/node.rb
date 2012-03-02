require File.expand_path('../../tree', __FILE__)

module Skylab::Porcelain
  module Tree
    SEPARATOR = '/'
  end
  class Tree::Node < Hash
    def children
      self[:children] ||= Tree::Children.new
    end
    def children?
      !! self[:children]
    end
    def find path_arr
      path_arr.kind_of?(Array) or path_arr = path_arr.to_s.split(Tree::SEPARATOR)
      _find path_arr, false
    end
    def find! path_arr, &block
      path_arr.kind_of?(Array) or path_arr = path_arr.to_s.split(Tree::SEPARATOR)
      _find path_arr, true, &block
    end
    def _find path_arr, create, &block
      path_arr.empty? and return self
      path_arr = path_arr.dup
      slug = path_arr.shift
      unless child = children[slug]
        if create
          child = self.class.build({:slug => slug}, &block) # @add_parent
          children[child.key] = child # let child choose its key!
        else
          return nil
        end
      end
      if path_arr.empty?
        child
      else
        child._find path_arr, create, &block
      end
    end
    def longest_common_base_path
      children? or return nil
      case children.size
      when 0
        nil # should be covered by above but whatever
      when 1
        downstream = children.first.longest_common_base_path
        downstream ||= []
        downstream.unshift children.first.key
      else
        key ? [] : nil # sorry i do not understand this.  arrived at via tests
      end
    end
    def initialize hash=nil
      hash and hash.each { |k, v| self[k] = v }
      yield(self) if block_given?
    end
    def key
      self[:slug]
    end
    def merge! node, opts=nil
      ks = node.keys
      if opts and opts[:except]
        ks -= opts[:except]
      end
      ks.each do |k|
        val = node[k]
        if ! self[k]
          self[k] = (val.respond_to?(:dup) && ! val.kind_of?(Symbol)) ? val.dup : val
        else
          case val
          when String, Symbol
            self[k].kind_of?(Array) or self[k] = [self[k]]
            self[k] |= [val]
          when Array
            self[k].kind_of?(Array) or self[k] = [self[k]]
            self[k] |= val
          else
            merge_other!(k, val)
          end
        end
      end
      self
    end
    def _paths arr, prefix
      is_root =  !(self[:slug] || prefix)
      if ! is_root
        my_path = [prefix, key,('' if children?)].compact.join(Tree::SEPARATOR)
        arr.push(my_path)
      end
      if children?
        my_prefix = is_root ? nil : [prefix, key].compact.join(Tree::SEPARATOR)
        children.each { |node| node._paths(arr, my_prefix) }
      end
      nil
    end
    def text opts=nil, &block
      fly = TextLine.new # can be turned into an option if needed to
      Locus.new( * [opts].compact ).traverse(self) do |node, meta|
        block.call(fly.clear!.update!(prefix(meta), node.send(name_accessor)))
      end # returns recursive count of leaf nodes
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
  class << Tree::Node
    alias_method :build, :new
    def combine nodes, lambdii=nil
      lambdii ||= { keymaker: ->(n) { n.key } }
      keymaker = lambdii[:keymaker] or fail("keymaker lambda is required")
      # map each node with its key, in both a hash and an array
      array = nodes.map { |node| [keymaker.call(node), node] }
      # map each key with an array of indexes into the above array
      hash = Hash.new { |h, k| h[k] = [] }
      array.each_with_index { |arr, idx| hash[arr.first].push idx }
      # if the hash is a size 1 then all nodes at this level are a match (per keymaker)
      case hash.size
      when 0
        nil
      when 1
        combined = array.reduce(new) { |m, n| m.merge!(n[1], :except => [:children] ) }
        order = []
        childs_by_name = array.reduce(Hash.new { |h, k| order.push(k) ; h[k] = [] }) do |m, n|
          n[1].children? and n[1].children.each { |c| m[keymaker.call(c)].push c } ; m
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
    def from_paths paths, &block
      paths.reduce(new(&block)) do |node, path|
        node.find!(path.to_s.split(Tree::SEPARATOR), &block)
        node
      end
    end
  end
end

