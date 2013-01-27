module Skylab::Treemap
  class Models::Node
    extend Autoloader

    prop_a = [ :indent, :content, :line_number ].freeze

    prop_a.each { |p| attr_reader p }

    def children
      @children or fail "no"
      ::Enumerator.new do |y|
        @children.each { |c| y << c }
        nil
      end
    end

    def children_length
      @children ? @children.length : 0
    end

    def first
      @children.first
    end

    def has_children
      children_length.nonzero?
    end

    def indent_length
      @indent ? @indent.length : 0
    end

    def last
      @children.last
    end

    def line_string
      "#{ @indent }#{ @content }"
    end

    def name
      @content
    end

    def push node
      ( @children ||= [] ).push node
    end

  protected

    prop_h_h = ::Hash[ prop_a.map { |p| [ p,
      -> v { instance_variable_set "@#{ p }", v } ] } ]

    define_method :initialize do |prop_h=nil|
      @indent = nil
      @content = nil
      @line_number = nil
      @children = nil
      if prop_h
        prop_h.each { |p, v| instance_exec v, & prop_h_h.fetch( p ) }
      end
    end
  end
end
