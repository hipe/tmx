require 'optparse'
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
      ancestors = self.ancestors[(self.ancestors.first == self ? 1 : 0)..-1] # singleton class does not have self as first
      klass = ancestors.detect { |a| a.class == ::Class and a.respond_to?(:_actions_cache) }
      mods = ancestors.select { |a| a.class == ::Module and a.respond_to?(:_actions_cache) }
      klass and mods -= klass.ancestors # wow it's if we are implementing ruby in ruby, how stupid
      @_actions_cache = ActionsCache.new.initiate
      [*mods, *[klass].compact].each { |anc| @_actions_cache.merge_in_duplicates_no_clobber! anc.actions }
      @_actions_cache
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
    def merge_in_duplicates_no_clobber! actions
      actions.each { |a| @hash.key?(a.name) or cache(a.duplicate) }
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
  EventizedHelpKnob   = EventKnob.new(:default, :header, :two_col)
  ParseOptionsKnob    = EventKnob.new(:syntax, :help_flagged)
  SyntaxEventKnob     = EventKnob.new(:syntax)
  class Action
    def argument_syntax
      if ! @argument_syntax.respond_to?(:parse_arguments)
        @argument_syntax = ArgumentSyntax.parse_syntax(@argument_syntax.to_s)
      end
      @argument_syntax
    end
    attr_writer :argument_syntax
    def duplicate
      Action.new( :argument_syntax => argument_syntax.to_s, # !
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.duplicate)
    end
    def eventized_help(&block)
      option_syntax.eventized_option_help(&block)
    end
    def initialize opts={}, &block
      @argument_syntax = @name = @option_syntax = nil
      block and opts.merge!(self.class.definition(&block))
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
    def syntax
      [name, option_syntax.to_s, argument_syntax.to_s].compact.join(' ')
    end
  end
  class << Action
    def definition &block
      Class.new.class_eval do
        extend ClientModuleMethods
        def self.method_added method_name
          @current_definition ||= {}
          @current_definition[:method_name] = method_name
        end
        class_eval(&block)
        self
      end.instance_variable_get('@current_definition')
    end
    def nameize sym
      sym.to_s.gsub('_', '-').intern
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
    def build_parser context, option_parser = nil
      option_parser ||= OptionParser.new.tap do |op|
        op.base.long['help'] = ::OptionParser::Switch::NoArgument.new do
          throw :option_action, ->(rt, act) { rt.client.help(act) ; nil }
        end
      end
      each { |b| option_parser.instance_exec(context, &b) }
      option_parser
    end
    alias_method :duplicate, :dup # only as long as it's stateless
    HEADER = /\A +[^:]+:\z/
    def eventized_option_help(&block)
      empty? and return
      yield(knob = EventizedHelpKnob.new)
      renderer = r = ::OptionParser.new
      lucky_matcher = /\A(#{Regexp.escape(r.summary_indent)}.{#{r.summary_width}}[ ])(.+)\z/
      renderer.banner = ''
      renderer.separator ' options:'
      build_parser({}, renderer)
      renderer.to_s.split("\n").each do |line|
        case line
        when ''            ;
        when lucky_matcher ; knob.emit_two_col($1, $2)
        when HEADER        ; knob.emit_header(line)
        else               ; knob.emit_default(line)
        end
      end
    end
    def parse_options argv
      empty? and return nil
      yield( knob = ParseOptionsKnob.new )
      option_parser = build_parser(context = {})
      begin
        option_parser.parse! argv
      rescue ::OptionParser::ParseError => e
        knob.emit_syntax e
        context = false
      end
      context
    end
    def to_s
      0 == count and return nil
      build_parser({}).instance_variable_get('@stack')[2].list.map do |switch| # ick
        "[#{[(switch.short.first || switch.long.first), switch.arg].compact.join('')}]"
      end.join(' ')
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
      symbols.current and symbols.current.required? and return nope["expecting: #{Styles::e13b symbols.current}"]
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
    def init_porcelain &block
      @handlers = {}
      if block_given?
        if block.arity >= 1
          yield self
        else
          instance_eval(&block)
        end
      end
      @handlers[:default] ||= lambda { |e| $stderr.puts "(unhandled:) #{e}" }
    end
    alias_method :initialize, :init_porcelain
    def invoke argv
      @runtime = Runtime.new(argv, self)
      (method, args = @runtime.parse_argv) or return method
      send(method, *args)
    end
    # for now we work around any dependencies on an emitter pattern by requiring
    # that the client subscribe to all events if she wants any
    def on_all &block
      @handlers[:all] = block
    end
  end

  module Styles
    extend self
    _list = [nil, :strong, * Array.new(30), :green]
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
    attr_reader :client
    def emit type, event
      (@handlers[type] || @handlers[:all] || @handlers[:default]).call event
    end
    def initialize argv, client
      @argv = argv.dup
      @client = client
      @handlers = client.handlers
    end
    def invite *msgs
      msgs.each { |msg| emit(:validation_error_meta, msg) }
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
        return invite("Invalid action: #{e13b sym}", "Expecting #{render_actions}")
      argv = catch(:option_action) do
        action.parse_both(@argv) { |o| o.on_syntax { |e| emit(:syntax, e) } }
      end
      argv.kind_of?(Proc) and return argv.call(self, action) # option_action
      argv or begin
        emit(:usage, "usage: #{e13b "#{invocation_name} #{action.syntax}"}")
        emit(:ui, "Try #{e13b "#{invocation_name} #{action.name} -h"} for help.")
        return false
      end
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
      act = !(String === action) ? action : begin
        action == '-h' and action = 'help'
        act = actions[action.intern]
      end
      act or return emit(:error, "No such action #{e13b "\"#{action}\""}.  " <<
        "Try #{e13b invocation_name} #{render_actions} #{e13b "-h"}.")
      emit(:usage, "#{header 'usage:'} #{e13b "#{invocation_name} #{act.syntax}"}")
      act.eventized_help do |o|
        o.on_header { |s| emit(:help, header(s.strip)) }
        o.on_two_col { |a, b| emit(:help, "#{e13b a}#{b}") }
        o.on_default { |line| emit(:help, line) }
      end
    end
  end
end

