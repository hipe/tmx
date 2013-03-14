module Skylab::Snag

  class Models::Tag::Flyweight

    attr_reader :begin

    attr_reader :end

    def normalized_name
      name_string.intern
    end

    def range
      @begin .. @end
    end

    def render
      @node_body_string[ range ]
    end

    alias_method :to_s, :render

    def reset                     # when begin and end are no longer valid
      @begin = @end = nil         # and you want to go back to the way things
      nil                         # used to be right after you were constructed
    end

    def set beg, en
      @begin = beg
      @end = en
      nil
    end

  protected

    def initialize node_body_string
      @node_body_string = node_body_string
    end

    def name_string
      @node_body_string[ ( @begin + 1 ) .. ( @end ) ] # NECESSARY EVIL
    end
  end
end
