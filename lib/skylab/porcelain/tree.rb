require_relative '..'

module Skylab::Porcelain
  module Tree
    extend ::Skylab::Autoloader
  end
  class << Tree
    def from_paths paths
      Tree::Node.from_paths paths
    end
    Result = Struct.new(:node_count)
    def lines root, opts=nil
      fly = Tree::TextLine.new # flyweighting can be turned into an option if needed to
      loc = Tree::Locus.new(opts)
      Enumerator.new do |y|
        node_count = loc.traverse(root) do |node, meta|
          y << fly.reset!(loc.prefix(meta), loc.node_formatter.call(node))
        end
        Result.new(node_count)
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
