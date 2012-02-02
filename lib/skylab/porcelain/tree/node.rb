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
    def find! path_arr
      path_arr.empty? and return self
      path_arr = path_arr.dup
      slug = path_arr.shift
      unless child = children[slug]
        child = self.class.new # @add_parent
        child[:key] = slug
        children[slug] = child
      end
      if path_arr.empty?
        child
      else
        child.find! path_arr
      end
    end
    def initialize
      @children = nil
    end
    def key
      self[:key]
    end
    def _paths arr, prefix
      is_root =  !(self[:key] || prefix)
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
      if @keys.include?(key)
        array_put @keys[key], val
      else
        @keys[key] = length
        array_put length, val
      end
    end
    def initialize
      @keys = {}
    end
    attr_reader :keys
  end
  class << Tree::Node
    def from_paths paths
      paths.reduce(new) do |node, path|
        node.find! path.split(Tree::SEPARATOR)
        node
      end
    end
  end
end

