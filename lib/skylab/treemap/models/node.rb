module Skylab::Treemap
  class Models::Node
    def children
      @children or fail("no")
      Enumerator.new do |y|
        @children.each { |c| y << c }
      end
    end
    def children?
      @children and (0 < @children.size)
    end
    def children_length
      @children ? @children.length : 0
    end
    def content
      line_content
    end
    attr_accessor :indent
    def indent_length
      @indent ? @indent.length : 0
    end
    def initialize data=nil
      @children = @indent = nil
      update_attributes!(data) if data
    end
    def first
      @children.first
    end
    def last
      @children.last
    end
    attr_accessor :line_content
    attr_accessor :line_number
    def line_string
      "#{indent}#{line_content}"
    end
    def name
      line_content
    end
    def push node
      (@children ||= []).push node
    end
    def update_attributes! data
      data.each { |k, v| send("#{k}=", v) }
    end
  end
end

