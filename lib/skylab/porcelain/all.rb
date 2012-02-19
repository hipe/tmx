require 'optparse'
require 'strscan'
require File.expand_path('../tite-color', __FILE__)
require File.expand_path('../../../skylab', __FILE__)
require 'skylab/pub-sub/emitter'

module Skylab::Porcelain
  def self.extended mod
    mod.send(:extend, ClientModuleMethods)
    mod.send(:include, ClientInstanceMethods)
    mod.send(:include, Officious::Help) unless mod.ancestors.include?(Officious::Help)
  end
  module Dsl
    def action &block
      @current_definition ||= {}
      (@current_definition[:config_blocks] ||= []).push block
    end
    def argument_syntax str
      @current_definition ||= {}
      @current_definition[:argument_syntax] = str
    end
    def init_dsl
      @porcelain_config_blocks = Hash.new { |h, k| h[k] = [] }
      @current_definition = nil
    end
    def emits *a
      porcelain { emits(*a) }
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
    def porcelain &block
      @porcelain_config_blocks[:runtime_class].push block
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
    def visible
      me = self
      self.class.new(@cache) do |yielder|
        me.each do |a|
          yielder.yield(a) if a.visible?
        end
      end
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
    def config_blocks= arr
      arr.each { |b| instance_eval(&b) }
    end
    def duplicate
      Action.new( :argument_syntax => argument_syntax.to_s, # !
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.duplicate,
                  :visible         => visible)
    end
    def eventized_help(&block)
      option_syntax.eventized_option_help(&block)
    end
    def initialize opts={}, &block
      @argument_syntax = @name = @option_syntax = nil
      @visible = true
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
      argument_syntax = self.argument_syntax
      false == (opts = option_syntax.parse_options(argv, & o.to_proc)) and return
      argument_syntax.parse_arguments(argv, & o.to_proc) or return
      # experimental sugar to avoid the client having to do their own parsing in this scenario, apparently not necessary in 1.9!
      # if opts && argument_syntax.any? && ! argument_syntax.last.glob? && argv.length < argument_syntax.length
      #  argv.concat Array.new(argument_syntax.length - argv.length) # but still it is so dodgy!
      # end
      opts and argv.push(opts)
      argv
    end
    def syntax
      [name, option_syntax.to_s, argument_syntax.to_s].compact.join(' ')
    end
    def visible *a
      0 == a.length and return @visible
      @visible = a.first
    end
    alias_method :visible?, :visible
    attr_writer :visible
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
      case mixed
      when NilClass ; new
      when Proc     ; new.push mixed
      end
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
    HEADER = /\A +[^:]+:/
    def eventized_option_help(&block)
      empty? and return
      yield(knob = EventizedHelpKnob.new)
      renderer = r = ::OptionParser.new
      lucky_matcher = /\A(#{Regexp.escape(r.summary_indent)}.{1,#{r.summary_width}})[ ]*(.*)\z/
      renderer.banner = ''
      build_parser({}, renderer)
      lines = renderer.to_s.split("\n")
      once = false
      lines.each do |line|
        case line
        when ''            ; # we might emit this after all
        when lucky_matcher ;
                           ; once ||= (knob.emit_header('options') || true)
                           ; knob.emit_two_col($1, $2)
        when HEADER        ; knob.emit_header(*line.strip.split(':', 2))
        else               ; knob.emit_default(line)
        end
      end
    end
    def parse_options argv
      empty? and ! Officious::Help::SWITCHES.include?(argv.first) and return nil
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
      build_parser({}).instance_variable_get('@stack')[2].list.select{ |s| s.kind_of?(::OptionParser::Switch) }.map do |switch| # ick
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
    def init_porcelain &block
      @runtime_event_subscriptions = block
    end
    alias_method :initialize, :init_porcelain
    def invoke argv
      bs = self.class.instance_variable_get('@porcelain_config_blocks')
      if @runtime_event_subscriptions
        es = @runtime_event_subscriptions
        bs[:runtime_instance] << -> { es.call(self) }
      end
      @runtime = Runtime.new(argv, self, bs)
      (method_name, args = @runtime.parse_argv) or return method_name
      res = send(method_name, *args)
      false == res and @runtime.invite(self.class.actions[method_name])
      res
    end
  end

  module Styles
    include TiteColor
    extend self
    def e13b str   ; stylize str, :green          end
    def header str ; stylize str, :strong, :green end
  end

  class Runtime
    include Styles
    extend ::Skylab::PubSub::Emitter
    emits({
      :error         => :all,
      :info          => :all,
      :help          => :info,
      :ui            => :info,
      :usage         => :info,
      :syntax        => :info,
      :runtime_issue => :error
    })
    def actions
      @client.class.actions
    end
    attr_reader :client
    def find_action str
      sym = str.intern
      if exact = actions.detect { |a| sym == a.name }
        return exact
      elsif self.singleton_class.fuzzy_match
        matcher = /\A#{Regexp.escape str}/
        found = actions.select { |a| matcher =~ a.name.to_s }
        case found.size
        when 0 ; # fallthru
        when 1 ; return found.first
        else
          return issue("Ambiguous action #{e13b str}. Did you mean #{found.map{ |a| e13b(a.name) }.join(' or ')}?")
        end
      end
      issue("Invalid action: #{e13b str}", "Expecting #{render_actions}")
    end
    def initialize argv, client, bs = nil
      @argv = argv.dup
      @client = client
      bs and bs = bs.dup
      if bs and defs = bs.delete(:runtime_class)
        defs.each { |b| singleton_class.instance_exec(&b) }
      end
      if bs and defs = bs.delete(:runtime_instance)
        defs.each { |b| instance_exec(&b) }
      end
      bs.any? and fail("no: #{bs.keys}")
      unless event_listeners[:all]
        on_all { |e| e.touched? or $stderr.puts(" * #{invocation_name}: #{e}") }
      end
    end
    def invite action=nil
      if action
        emit(:ui, "Try #{e13b "#{invocation_name} #{action.name} -h"} for help.")
      else
        emit(:ui, "Try #{e13b "#{invocation_name} -h"} for help.")
      end
      nil
    end
    def issue *msgs
      # action = msgs.shift if msgs.any? && ! msgs.first.kind_of?(String)
      msgs.each { |msg| emit(:runtime_issue, msg) }
      invite
    end
    def invocation_name
      File.basename $PROGRAM_NAME
    end
    def parse_argv
      @argv.empty? and return issue("Expecting #{render_actions}.")
      Officious::Help::SWITCHES.include?(@argv.first) and @argv[0] = 'help' # might bite one day
      action = find_action(@argv.shift) or return action
      argv = catch(:option_action) do
        action.parse_both(@argv) { |o| o.on_syntax { |e| emit(:syntax, e) } }
      end
      argv.kind_of?(Proc) and return argv.call(self, action) # option_action
      argv or begin
        emit(:runtime_issue, "usage: #{e13b "#{invocation_name} #{action.syntax}"}")
        issue action
        return false
      end
      [action.method_name, argv]
    end
    def render_actions
      "{#{actions.visible.map{ |a| e13b(a.name) }.join('|')}}"
    end
  end

  class << Runtime
    def fuzzy_match *a
      case a.size ; when 1 ; @fuzzy_match = a.first
                    when 0 ; @fuzzy_match.nil? ? true : @fuzzy_match
                    else   ; raise ArgumentError.new('no') ; end
    end
  end

  module Officious ; end

  module Officious::Help
    SWITCHES = %w(-h --help)
    extend ::Skylab::Porcelain
    argument_syntax '[<action>]'
    action { visible false }
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
        o.on_header { |name, content=nil| emit(:help, "#{header("#{name}:")}#{content}") }
        o.on_two_col { |a, b| emit(:help, "#{e13b a}#{b}") }
        o.on_default { |line| emit(:help, line) }
      end
    end
  end
end

