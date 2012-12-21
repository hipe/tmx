module Skylab::Treemap

  module CLI::OptionSyntaxReflection
    def options
      (@options ||= begin
        ->() do
          i = -1 ; fresh = false ; options = Options.new
          on_definition_added[:option_syntax_reflection] = ->() { fresh = false ; options.taint! }
          update = ->() do
            Recorder.new(options).tap { |r| r.merge_definition!(definitions[i+=1]) while (i+1) < definitions.length } # !
            options[:help] ||= CLI::OptionSyntaxReflection::OptionReflection.new(:help, 'help', 'h') # not sure
            fresh = true
          end
          ->() { fresh or update.call ; options }
        end.call
      end).call
    end
  end
end

module Skylab::Treemap
  class CLI::OptionSyntaxReflection::Options < Hash
    def by_switch
      @by_switch ||= begin
        h = { }
        values.each do |opt|
          opt.short_stem and h[opt.short_name] = opt
          opt.long_stem and h[opt.long_name_no_no] = opt
          opt.no? and h[opt.long_name] = opt
        end
        h
      end
    end
    def taint!
      @by_switch = nil
    end
  end
end

module Skylab::Treemap::CLI::OptionSyntaxReflection
  class OptionReflection < Struct.new(:name, :long_stem, :short_stem, :no, :long_rest, :short_rest)
    RE_LONG = %r{\A--(?<no>\[no-\])?(?<long_name_stem>[^\[\]=\s]{2,})(?<long_rest>.+)?\z}
    RE_SHORT = %r{\A-(?<short_name_stem>[^-\[= ])(?<short_rest>[-\[= ].*)?\z}
    def self.build name, args, &error
      opts = args.pop if args.last.kind_of?(Hash)
      looking = [RE_LONG, RE_SHORT]
      md = {}
      match = ->(part) do
        if String === part
          _md = nil
          if idx = (0..looking.size-1).detect { |i| _md = looking[i].match(part) }
            looking[idx] = nil
            looking.compact!
            _md.names.each { |n| md[n.intern] = _md[n] }
            _md
          end
        end
      end
      args.each { |part| match.call(part) and looking.empty? and break }
      if ! md[:long_name_stem]
        error and error.call("couldn't find a suitable long name in #{args.inspect}")
        return false
      end
      self.new(name, md[:long_name_stem], md[:short_name_stem],
              md[:no], md[:long_rest], md[:short_rest], *[opts].compact)
    end
    def arg?
      long_rest or short_rest # really really not robust
    end
    # this is only for a hack. do not use.
    def build_regexp
      aa = [] ; a = []
      if long_name
        a.push '\A--'
        no? and a.push '(?<no>no-)?'
        a.push "(?<long_stem>#{Regexp.escape(long_stem)})"
        arg? and a.push '(?:=(?<long_arg>.*))?'
        aa.push a.push('\z').join('')
      end
      a.clear
      if short_name
        esc = Regexp.escape(short_stem)
        a.push "\\A(?<short_before>-(?:(?!-|#{esc}).)*)#{esc}"
        arg? and a.push '(?<short_arg>.+)?\z'
        aa.push a.join('')
      end
      Regexp.new(aa.join('|'))
    end
    def default= val
      @has_default = true
      @default = val
    end
    attr_reader :default, :has_default
    alias_method :default?, :has_default
    def initialize(*a)
      @has_default = @default = nil
      Hash === a.last and self.default = a.pop[:default] # careful!
      super(*a)
    end
    def long_name
      long_stem && "--#{no}#{long_stem}"
    end
    def long_name_no_no
      long_stem && "--#{long_stem}"
    end
    def optarg?
      arg? and arg?.match(/^ *\[.+\]$/) # this is asking for trouble
    end
    alias_method :no?, :no
    # total hack to try and parse *one* option out of an argv
    def parse argv
      res, = _parse(argv)
      res
    end
    def _parse argv
      re = build_regexp
      md = md = ret = nil ; knock = []
      if idx = (0...argv.length).detect { |i| md = re.match(argv[i]) }
        set_ret = false
        if md[:long_stem]
          knock.push [idx, :done]
        elsif '-' == md[:short_before]
          knock.push [idx, :done]
        else
          knock.push [idx, :sub, md[:short_before]]
        end
        if arg?
          if ret = md[:long_arg] || md[:short_arg]
            # nothing
          elsif (idx+1) < argv.length and /^[^-]/ =~ argv[idx+1].to_s
            ret = argv[idx+1]
            knock.push [idx+1, :done]
          elsif optarg?
            set_ret = true
          else
            knock.pop # failed to match arg, rewind
          end
        else
          set_ret = true
        end
        set_ret and ret = (no? and md[:no]) ? false : true
      end
      [ret, knock, md]
    end
    def parse! argv
      ret, knock, md = _parse(argv)
      knock.each do |idx, inst, data=nil|
        case inst
        when :done ; argv[idx] = nil
        when :sub  ; argv[idx] = data
        end
      end.any? and argv.compact!
      ret
    end
    def short_name
      short_stem && "-#{short_stem}"
    end
    alias_method :short, :short_name # it's nice to have a shorthand for Stylus#param
  end
  class Recorder
    def initialize result_hash
      @defaults = {}
      @stack = []
      @result = result_hash
    end
    def []= k, v
      @set.call(k, v)
      v
    end
    def [] k
      @get.call(k)
    end
    def documentor?
      false
    end
    def more *a
      []
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
    def merge_option_definition! *parts, block
      block or return error("option reflection not implemented for option definitions without a block (#{parts.inspect})")
      @last_key = nil
      block.call(* Array.new(block.arity.abs))
      @last_key or return error("block did not set a value in options hash in definition of #{parts.inspect}")
      @defaults.key?(@last_key) and parts.push(default: @defaults[@last_key])
      opt = OptionReflection.build(@last_key, parts) { |e| return error(e) }
      if exist = @result[opt.name]
        if exist.long_name != opt.long_name
          return error("redifinition of #{opt.name} did not match: #{exist.long_name} vs. #{opt.long_name}")
        end
      else
        @result[opt.name] = opt
      end
    end
    def separator *a # compat
    end
  end
end

