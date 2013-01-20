# encoding: utf-8
module ::Skylab::Porcelain
  class Tree::Locus < ::Struct.new :blank, :crook, :node_formatter, :pipe, :tee

    attr_accessor :branch

    attr_accessor :empty

    def traverse root, &block
      @level = 0
      @block = block
      @prefix_stack = []
      _traverse root
    end

    def prefix meta
      meta[:level].nil? and return ''
      "#{ @prefix_stack * '' }#{ meta[:is_last] ? crook : tee }"
    end

    def parent_prefix meta
      meta[:level].nil? and return ''
      meta[:is_last] ? blank : pipe
    end

  protected

    def initialize opts=nil
      super '  ', ' └', nil, ' │', ' ├'
      opts and opts.each { |k, v| send "#{ k }=", v }
      self.node_formatter ||= :name
      if ::Symbol === self.node_formatter
        formatter_method_name = self.node_formatter
        self.node_formatter = ->(n) { n.send(formatter_method_name) }
      end
    end

    def _push meta
      @level += 1
      @prefix_stack.push parent_prefix( meta )
    end

    def _pop meta
      @level -= 1
      @prefix_stack.pop
    end

    def _traverse root, meta={ }
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
  end
end
