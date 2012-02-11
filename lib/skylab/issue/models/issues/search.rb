module Skylab::Issue
  class Models::Issues::Search
    KEYS = [:identifier]
    def initialize emitter, query
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
    JUST_DIGITS = %r{\A(.*[^\d])?(\d+)([^\d].*)?\z}
    def identifier= v
      unless md = JUST_DIGITS.match(v.to_s)
        return error("invalid identifier, needs some digit: #{v.inspect}")
      end
      unless (extra = "#{md[1]}#{md[3]}").empty?
        emit :info, "(ignoring #{extra.inspect} in search criteria.)"
      end
      @identifier = md[2].to_i
      @index[:identifier] ||= begin
        @or[idx = @or.length] = ->(issue) { issue.identifier.to_i == @identifier }
        idx
      end
      v
    end
    attr_reader :identifer
    def include? issue
      @or.empty? and @or.push(->(i) { true })
      @or.detect { |node| node.call(issue) }
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

