module Skylab::Issue
  class Models::Issues::Search
    KEYS = [:identifier]
    def initialize emitter, query
      @valid = true
      emitter.respond_to?(:emit) or raise ArgumentError.new('nope')
      @emitter = emitter
      @criteria_keys = []
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
      @criteria_keys.push :identifier
      target_integer = md[2].to_i
      @identifier_filter = ->(issue) { target_integer == issue.identifier.to_i }
      v
    end
    attr_reader :identifer
    def _include_identifier? issue
      @identifier_filter[issue]
    end
    def include? issue
      @criteria_keys.empty? and return false
      @criteria_keys.detect { |k| ! send("_include_#{k}?", issue) } and return false
      true
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

