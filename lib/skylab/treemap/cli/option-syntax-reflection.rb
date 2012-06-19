module Skylab::Treemap

  module CLI::OptionSyntaxReflection
    def options
      @options ||= begin
        rec = Recorder.new
        definitions.each do |d|
          rec.merge_definition! d
        end
        rec.result
      end
    end
  end
end

module Skylab::Treemap::CLI::OptionSyntaxReflection
  class OptionReflection < Struct.new(:name, :long_stem, :no)
    def long_name
      "--#{no}#{long_stem}"
    end
  end
  class Recorder
    def initialize
      @defaults = {}
      @stack = []
      @result = {}
    end
    def []= k, v
      @set.call(k, v)
      v
    end
    def [] k
      @get.call(k)
    end
    def error msg
      fail(msg) # it's very possible we will choose to ignore errors and have this be unobtrusive
      false
    end
    def on(*a, &b)
      @on.call(*a, &b)
    end
    def merge_definition! d
      @set = ->(k, v)   { @defaults[k] = v }
      @get = ->(k)      { @defaults[k]     }
      @on  = ->(*a, &b) { @stack.push( [*a, b] ) }
      instance_exec(self, &d)
      @set = ->(k, _)    { @last_key = k    }
      while parts = @stack.shift
        merge_option_definition!(*parts)
      end
    end
    RE = %r{\A--(?<no>\[no-\])?(?<long_name_stem>[^\[\]=\s]{2,})}
    def merge_option_definition! *parts, block
      block or return error("option reflection not implemented for option definitions without a block (#{parts.inspect})")
      @last_key = nil
      block.call(* Array.new(block.arity.abs))
      @last_key or return error("block did not set a value in options hash in definition of #{parts.inspect}")
      md = nil
      parts.detect { |s| String === s and md = RE.match(s) } or return error("couldn't find a suitable long name in #{parts.inspect}")
      opt = OptionReflection.new(@last_key, md[:long_name_stem], md[:no])
      if exist = @result[opt.name]
        if exist.long_name != opt.long_name
          return error("redifinition of #{opt.name} did not match: #{exist.long_name} vs. #{opt.long_name}")
        end
      else
        @result[opt.name] = opt
      end
    end
    attr_reader :result
  end
end

