require 'strscan'

module Skylab ; end

module Skylab::Porcelain
  def self.extended mod
    mod.send(:extend, ClientModuleMethods)
    mod.send(:include, ClientInstanceMethods)
    mod.send(:include, Officious::Help) unless mod.ancestors.include?(Officious::Help)
  end
  module Dsl
    def argument_syntax str
      @current_definition ||= {}
      @current_definition[:argument_syntax] = str
    end
    def init_dsl
      @current_definition = nil
    end
    def method_added method_name
      if @current_definition
        defn = @current_definition ; @current_definition = nil
        defn[:method_name] = method_name
        _actions_cache.cache Action.new(defn)
      end
    end
    def option_syntax &block
      @current_definition ||= {}
      @current_definition[:option_syntax] = block
    end
  end
  module ClientModuleMethods
    include Dsl
    def self.extended mod
      mod.init_dsl
    end
    def actions
      cache = _actions_cache
      ActionEnumerator.new(cache) do |yielder|
        cache.each { |act| yielder << act }
        public_instance_methods(false).select { |m| ! cache.key?(m) }.each do |method_name|
          yielder << cache.cache(Action.new(:method_name => method_name))
        end
      end
    end
    def _actions_cache
      instance_variable_defined?('@_actions_cache') and return @_actions_cache
      if anc = ancestors[(ancestors.first == self ? 1 : 0)..-1].detect { |a| a.respond_to?(:_actions_cache) }
        anc.actions.each { }  # refresh the cache with all latest defined methods (ick!)
        @_actions_cache = anc._actions_cache.duplicate
      else
        @_actions_cache = ActionsCache.new.initiate
      end
    end
  end
  class ActionsCache
    def [] k
      @hash[k].kind_of?(Symbol) ? @hash[@hash[k]] : @hash[k]
    end
    def cache action
      @hash.key?(action.name) or @order.push action.name
      @hash[action.method_name] = action.name
      @hash[action.name] = action
    end
    def duplicate
      self.class.new.tap do |other|
        other.instance_variable_set('@order', @order.dup)
        other.instance_variable_set('@hash', Hash[ * @hash.map{ |k, v|
          [ k , v.kind_of?(Symbol) ? v : v.duplicate ]
        }.flatten ] )
      end
    end
    def each &block
      @order.each { |k| block.call(@hash[k]) }
    end
    def initiate
      @hash = {}
      @order = []
      self
    end
    def key? key
      @hash.key? key
    end
  end
  class ActionEnumerator < Enumerator
    def initialize cache, &block
      @cache = cache
      super(&block)
    end
    def [] sym
      @cache.key?(sym) and return @cache[sym]
      detect { |a| a.name == sym }
    end
  end
  class EventKnob < Hash
    class << self
      alias_method :orig_new, :new
    end
    def self.new *event_names
      event_names.map!(&:intern)
      Class.new(self).class_eval do
        singleton_class.send(:define_method, :inspect) { "EventKnob(#{event_names.join(' ')})" }
        singleton_class.send(:define_method, :event_names) { @event_names ||= event_names }
        def self.new(*a)
          orig_new(*a)
        end
        [:unhandled, :all, *event_names].each do |e|
          define_method("on_#{e}") do |&b|
            b or raise ArgumentError.new("on_#{e}() requires a block")
            self[e] = b
          end
        end
        event_names.each do |e|
          define_method("emit_#{e}") do |*a|
            (self[e] || self[:all] || (self[:unhandled] ||= _build_default_unhandled)).call(*a)
          end
        end
        self
      end
    end
    def _build_default_unhandled
      ->(*a) { $stderr.puts("(unhandled event:) #{a.first}", *a[1..-1]) }
    end
    def to_proc
      this = self
      lambda do |eh|
        this.class.event_names.each do |en|
          eh.send("on_#{en}") { |*e| this.send("emit_#{en}", *e) }
        end
      end
    end
  end
  SyntaxEventKnob = EventKnob.new(:syntax)
  class Action
    def self.nameize sym
      sym.to_s.gsub('_', '-').intern
    end
    def argument_syntax
      if ! @argument_syntax.respond_to?(:parse_arguments)
        @argument_syntax = ArgumentSyntax.parse_syntax(@argument_syntax.to_s)
      end
      @argument_syntax
    end
    attr_writer :argument_syntax
    def duplicate
      Action.new( :argument_syntax => argument_syntax.to_s,
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.duplicate)
    end
    def help
      yield( o = SyntaxEventKnob.new )
      o.emit_syntax [name, option_syntax.to_s, argument_syntax.to_s].compact.join(' ')
    end
    def initialize opts
      @argument_syntax = @name = @option_syntax = nil
      opts.each { |k, v| send("#{k}=", v) }
    end
    attr_reader :method_name
    def method_name= sym
      @method_name = sym
      @name.nil? and @name = self.class.nameize(sym)
      sym
    end
    attr_accessor :name
    def option_syntax
      unless @option_syntax.respond_to?(:parse_options)
        @option_syntax = OptionSyntax.build(@option_syntax)
      end
      @option_syntax
    end
    attr_writer :option_syntax
    def parse_both argv
      yield( o = SyntaxEventKnob.new )
      false == (opts = option_syntax.parse_options(argv, & o.to_proc)) and return
      argument_syntax.parse_arguments(argv, & o.to_proc) or return
      opts and argv.push(opts)
      argv
    end
  end
  class OptionSyntax < Array
    def self.build mixed
      syntax = new
      case mixed
      when NilClass # noop
      when Array
        no = mixed.detect { |o| ! o.kind_of?(Proc) } and
          raise RuntimeError.new("expected array of procs, found #{no.class}")
        syntax.concat mixed
      when Proc ; syntax.push mixed
      else raise RuntimeError.new("expecting array or nil had #{mixed.class}")
      end
      syntax
    end
    alias_method :duplicate, :dup # only as long as it's stateless
    def parse_options *x
      empty? and return nil
      yield( o = SyntaxEventKnob.new )
      o.emit_syntax("flougger")
      {}
    end
    def to_s
      0 == count and return nil
      '[fake opts!]'
    end
  end
  class ArgumentSyntax < Array
    def self.parse_syntax str
      p = StringScanner.new(str)
      syntax = new
      until p.eos?
        p.skip(/ /)
        matched = p.scan(Parameter::REGEX) or
          raise RuntimeError.new("failed to parse: #{p.rest.inspect}#{" (after #{syntax.last.to_s.inspect})" if syntax.any?}")
        matchdata = Parameter::REGEX.match(matched)
        syntax.push Parameter.new(:matchdata => matchdata)
      end
      syntax.validate
    end
    def parse_arguments argv, &block
      ArgumentParse[self, argv, &block]
    end
    def to_s
      0 == count and return nil
      join(' ')
    end
    def validate
      signature = map { |p| p.glob? ? 'G' : 'g' }.join('')
      /G.*G/ =~ signature and raise RuntimeError.new("globs cannot be used more than once (had: #{signature})")
      /\AGg/ =~ signature and raise RuntimeError.new("globs cannot occur at the beginning (had: #{signature})")
      /gGg/  =~ signature and raise RuntimeError.new("globs cannot occur in the middle (had: #{signature})")
      signature = map { |p| p.required? ? 'o' : 'O' }.join('')
      /\AOo/ =~ signature and raise RuntimeError.new("optionals cannot occur at the beginning (had: #{signature})")
      /oO+o/ =~ signature and raise RuntimeError.new("optionals cannot occur in the middle (had: #{signature})")
      self
    end
    ArgumentParse = lambda do |syntax, argv, &block|
      # (i blame Davis Frank for inspiring me to experiment with writing this like this)
      block[o = SyntaxEventKnob.new]
      tokens = ArrayAsTokens.new(argv)
      symbols = ArrayAsTokens.new(syntax)
      nope = lambda { |msg| o.emit_syntax(msg) ; false }
      while tokens.any?
        symbol = symbols.current or return nope["unexpected argument: #{tokens.current.inspect}"]
        tokens.advance
        symbol.glob? or symbols.advance
      end
      symbols.current and symbols.current.required? and return nope["expecting #{symbols.current}"]
      true
    end
  end
  class ArgumentSyntax::ArrayAsTokens
    def initialize arr
      @current = 0
      @length = arr.count
      @arr = arr
    end
    def advance
      @current += 1
    end
    def any?
      @current < @length
    end
    def current
      @arr[@current]
    end
  end
  class Parameter
    NAME = %r{<([_a-z]+)>}
    REGEX = %r{
           #{NAME.source} [ ]* ( \[ (?: <\1> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )?
      | \[ #{NAME.source} [ ]* ( \[ (?: <\3> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )? \]
    }x
    def glob? ; @max.nil? end
    def initialize opts
      opts.each { |k, v| send("#{k}=", v) }
    end
    def matchdata= md
      @name = (md[1] || md[3]).intern
      if md[1]
        @min = 1
        @max = md[2] ? nil : 1
      else
        @min = 0
        @max = md[4] ? nil : 1
      end
    end
    def required? ; @min > 0 ; end
    def to_s
      ellipses = @max.nil? ? " [<#{@name}>[...]]" : ''
      required? ? "<#{@name}>#{ellipses}" : "[<#{@name}>#{ellipses}]"
    end
  end

  # .. below is invocation mechanics
  module ClientInstanceMethods
    attr_reader :handlers
    def init_porcelain
      @handlers = {}
      yield self if block_given?
      @handlers[:all] ||= lambda { |e| $stderr.puts e }
    end
    alias_method :initialize, :init_porcelain
    def invoke argv
      @runtime = Runtime.new(argv, self)
      (method, args = @runtime.parse_argv) or return method
      send(method, *args)
    end
    # for now we work around any dependencies on emitters
    def on_all &block
      @handlers[:all] = block
    end
  end

  module Styles
    _list = [nil, :string, * Array.new(30), :green]
    MAP = Hash[ * _list.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def e13b str   ; stylize str, :green          end
    def header str ; stylize str, :strong, :green end
    def stylize str, *styles
      "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m"
    end
    def unstylize str
      str.to_s.gsub(/\e\[\d+(?:;\d+)*m/, '')
    end
  end

  class Runtime
    include Styles
    def actions
      @client.class.actions
    end
    def emit type, event
      if @handlers[type]
        @handlers[type].call event
      elsif @handlers[:all]
        @handlers[:all].call event
      else
        $stderr.puts e
      end
    end
    def initialize argv, client
      @argv = argv.dup
      @client = client
      @handlers = client.handlers
    end
    def invite msg=nil
      msg and emit(:usage, msg)
      emit(:ui, "Try #{e13b "#{invocation_name} -h"} for help.")
      nil
    end
    def invocation_name
      File.basename $PROGRAM_NAME
    end
    def parse_argv
      @argv.empty? and return invite("Expecting #{render_actions}.")
      %w(-h --help).include?(@argv.first) and @argv[0] = 'help'
      sym = @argv.shift.intern # fuzzy match later
      action = actions.detect { |a| a.name == sym } or
        return invite("Invalid action: #{e13b sym}.\n Expecting #{render_actions}.")
      argv = action.parse_both(@argv) { |o| o.on_syntax { |e| emit(:usage, e) } } or
        return emit(:ui, "Try #{e13b "#{invocation_name} #{action.name} -h"} for help.") && nil
      [action.method_name, argv]
    end
    def render_actions
      "{#{actions.map{ |a| e13b(a.name) }.join('|')}}"
    end
  end

  module Officious ; end

  module Officious::Help
    extend ::Skylab::Porcelain
    argument_syntax '[<action>]'
    def help action=nil
      Plumbing.new(@runtime, action).run
    end
  end
  class Officious::Help::Plumbing
    include Styles
    def initialize runtime, action
      @action = action
      @runtime = runtime
    end
    %w(actions emit invocation_name render_actions).each do |method| # delegates
      define_method(method) { |*a, &b| @runtime.send(method, *a, &b) }
    end
    def run
      @action and return help_action @action
      emit(:ui, "#{header 'usage:'} #{invocation_name} #{render_actions} [opts] [args]")
      emit(:ui, "For help on a particular subcommand, try #{e13b "#{invocation_name} <subcommand> -h"}.")
    end
    def help_action action
      action == '-h' and action = 'help'
      act = actions[action.intern]
      act ||= actions.include?(action) && Action.new(:name => action, :method => method(action))
      act or return emit(:error, "No such action #{e13b "\"#{action}\""}.  " <<
        "Try #{e13b invocation_name} #{render_actions} #{e13b "-h"}.")
      act.help do |o|
        o.on_syntax { |e| emit(:payload, "#{header 'syntax:'} #{e13b "#{invocation_name} #{e}"}") }
      end
    end
  end
end

