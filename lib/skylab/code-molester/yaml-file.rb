require 'yaml'
require File.expand_path('../../face/path-tools', __FILE__)
module Skylab; end

module Skylab::CodeMolester
  module Yaml
    module ModuleMethods
      def syck_to_node foo
        tree = Tree.new
        foo.value.each do |key, val|
          if :map == val.kind
            subtree = syck_to_node val
          else
            tree[key.value] = val.value
          end
        end
        tree
      end
    end
    class ValueNode
      def initialize key, value
        @key = key.intern
        @value = value
      end
      attr_reader :key
      attr_accessor :value
      def leaf?
        true
      end
    end
    module BufferAdapter
      def self.[] str
        str.extend self
        str
      end
      def puts str
        str ||= ''
        str =~ /\n\Z/ or str = "#{str}\n"
        concat str
      end
    end
    class Tree
      def initialize name = nil
        @key = name ? name.intern : nil
        @children = []
      end
      def []= (k, v)
        k = k.intern
        if index = @children.index { |c| c.key == k }
          node = @children[index]
          if node.branch?
            node.value = v
          else
            @children[index] = ValueNode.new(k, v)
          end
        else
          @children.push ValueNode.new(k, v)
        end
      end
      def leaf?
        false
      end
      def node! name
        key = name.intern
        unless child = @children.detect { |c| c.key == key }
          child = Tree.new(name)
          @children.push(child)
        end
        child
      end
      def to_string margin=nil, opts=nil
        if opts.nil? && margin.kind_of?(Hash)
          opts = margin
          margin = ''
        end
        opts ||= {}
        opts[:indent_with] ||= '  '
        opts[:buffer] ||= BufferAdapter['']
        out = opts[:buffer]
        if @key
          out.puts "#{margin}#{@key}:"
          child_margin = "#{margin}#{opts[:indent_with]}"
        else
          child_margin = margin
        end
        @children.each do |node|
          if node.kind_of?(ValueNode)
            out.puts "#{child_margin}#{node.key}: #{node.value}"
          else
            node.to_string child_margin, opts
          end
        end
        out
      end
    end
  end
  class YamlFile
    extend Yaml::ModuleMethods
    def initialize path
      @path = path
      if File.exist?(@path)
        parsed = YAML.parse(File.read(@path))
        if false == parsed # empty file, special case
          @node = Yaml::Tree.new
        else
          @node = self.class.syck_to_node(parsed)
        end
      else
        @node = Yaml::Tree.new
      end
    end
    attr_reader :path
    def exists?
      File.exist?(@path)
    end
    def node! name
      @node.node! name
    end
    def pretty_path
      Skylab::Face::PathTools.pretty_path(@path)
    end
    def to_s
      @node.to_string
    end
    def write
      bytes = nil
      str = @node.to_string(:indent_with => '  ')
      len = str.length
      File.open(@path, 'w+') do |fh|
        fh.write str
        bytes = len
      end
      bytes
    end
  end
end
