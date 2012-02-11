require File.expand_path('../search/articulate', __FILE__)
module Skylab::Issue
  class Models::Issues::Search
    POSITIVE_INTEGER = %r{\A\d+\z}
    JUST_DIGITS = %r{\A(.*[^\d])?(\d+)([^\d].*)?\z}
    KEYS = [:identifier]
    def initialize emitter, query
      @counter = nil
      @valid = true
      emitter.respond_to?(:emit) or raise ArgumentError.new('nope')
      @emitter = emitter
      @or = []
      @index = {}
      query.each { |k, v| send("#{k}=", v ) }
    end
    def emit a, b
      @emitter.emit a, b
    end
    def error msg
      @valid = false
      emit :error, msg
      false
    end
    def identifier= v
      v.nil? and return @index[:identifier] && unset(:identifier)
      unless md = JUST_DIGITS.match(v.to_s)
        return error("invalid identifier, needs some digit: #{v.inspect}")
      end
      unless (extra = "#{md[1]}#{md[3]}").empty?
        emit :info, "(ignoring #{extra.inspect} in search criteria.)"
      end
      @identifier = md[2].to_i
      set(:identifier) { |issue| issue.identifier.to_i == @identifier }
      v
    end
    attr_reader :identifier
    def include? issue
      @or.empty? and set(:any) { |i| true }
      b = @or.detect { |node| node.call(issue) }
      if @counter and b
        if (@counter += 1) >= @last
          throw(:last_item, issue)
        end
      end
      b
    end
    attr_reader :last
    def last= num
      num.nil? and return (@last = @counter = nil)
      POSITIVE_INTEGER =~ num or return error("must be an integer: #{num}")
      @counter = 0
      @last = num.to_i
    end
    def set name, &test
      @index[name] ||= begin
        @or[idx = @or.length] = test
        idx
      end
    end
    def valid?
      @valid
    end
  end
  class << Models::Issues::Search
    def build(*a)
      s = new(*a)
      s.valid? ? s : false
    end
  end
end

