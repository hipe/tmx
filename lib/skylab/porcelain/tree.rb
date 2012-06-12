# encoding: utf-8

module Skylab
  module Porcelain
    # forward declaration for consistent indentation below
  end
end

module Skylab::Porcelain::Tree
  class Locus < Struct.new(:blank, :crook, :node_name, :pipe, :tee)
    attr_accessor :branch
    attr_accessor :empty
    def initialize opts=nil
      super('  ', ' └', nil, ' │', ' ├')
      opts and opts.each { |k, v| send("#{k}=", v) }
      self.node_name ||= :name
      if Symbol === self.node_name
        name_accessor = self.node_name
        self.node_name = ->(n) { n.send(name_accessor) }
      end
    end
    def traverse(root, &block)
      @level = 0
      @block = block
      @prefix_stack = []
      _traverse root
    end
    def _traverse root, meta={}
      @block.call root, meta
      sum = 1
      if root.children?
        _push meta
        last = root.children_length - 1
        root.children.each_with_index do |child, idx|
          sum += _traverse(child, {
            :is_first => (0 == idx),
            :is_last  => (last == idx),
            :level    => @level
          })
        end
        _pop meta
      end
      sum
    end
    def _push meta
      @level += 1
      @prefix_stack.push parent_prefix(meta)
    end
    def _pop meta
      @level -= 1
      @prefix_stack.pop
    end
    def prefix meta
      meta[:level].nil? and return ''
      "#{@prefix_stack * ''}#{meta[:is_last] ? crook : tee}"
    end
    def parent_prefix meta
      meta[:level].nil? and return ''
      meta[:is_last] ? blank : pipe
    end
  end
end

module Skylab::Porcelain
  class Tree::TextLine < Struct.new(:prefix, :name)
    def clear!
      self.prefix = self.name = nil
      self
    end
    def to_s
      "#{prefix}#{name}"
    end
    def update! prefix, name
      self.prefix = prefix
      self.name = name
      self
    end
  end
  class << Tree
    def from_paths paths
      require File.expand_path('../tree/node', __FILE__)
      Tree::Node.from_paths paths
    end
    def lines root, opts=nil
      fly = Tree::TextLine.new # flyweighting can be turned into an option if needed to
      loc = Tree::Locus.new( * [opts].compact )
      Enumerator.new do |y|
        loc.traverse(root) do |node, meta|
          y << fly.clear!.update!(loc.prefix(meta), loc.node_name[node])
        end
      end
    end
    def text root, opts=nil, &block
      enum = lines(root, opts)
      if block_given?
        enum.each(&block)
      else
        StringIO.new.tap { |o| enum.each { |s| o.puts(s) } }.string
      end
    end
  end
end

