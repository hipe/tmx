# encoding: utf-8

module Skylab
  module Porcelain
    # forward declaration for consistent indentation below
  end
end

module Skylab::Porcelain::Tree
  class Locus
    def initialize opts={}
      @branch      = ' ├'
      @pipe        = ' │'
      @last_branch = ' └'
      @blank       = '  '
      @name_accessor = :name
      opts.each { |k, v| send("#{k}=", v) }
    end
    attr_accessor :branch, :pipe, :last_branch, :empty
    attr_accessor :name_accessor
    def traverse(root, &block)
      @level = 0
      @block = block
      @prefix_stack = []
      _traverse root
    end
    def _traverse root, meta={}
      @block.call root, meta
      sum = 1
      if root.children and root.children.any?
        _push meta
        last = root.children.length - 1
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
      mine = case true
             when (meta[:is_last]) ; @last_branch
             else                  ; @branch
             end
      leader = @prefix_stack.join('')
      "#{leader}#{mine}"
    end
    def parent_prefix meta
      meta[:level].nil? and return ''
      if meta[:is_first]
        if meta[:is_last]
          @blank
        else
          @pipe
        end
      elsif meta[:is_last]
        @blank
      else
        @pipe
      end
    end
  end
end

module Skylab::Porcelain
  class << Tree
    def view_tree root, opts={}, &block
      unless out = opts.delete(:out)
        require 'stringio'
        out = StringIO.new
        return_string = true
      end
      loc = Tree::Locus.new opts
      block ||= lambda do |node, meta|
        out.puts "#{loc.prefix(meta)}#{node.send(loc.name_accessor)}"
      end
      sum = loc.traverse(root, &block)
      if return_string
        out.rewind
        out.read
      else
        sum
      end
    end
  end
end

