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
  class Action
    def self.nameize sym
      sym.to_s.gsub('_', '-').intern
    end
    def argument_syntax
      NilClass === @argument_syntax and @argument_syntax = ''
      String === @argument_syntax and @argument_syntax = ArgumentSyntax.parse(@argument_syntax)
      @argument_syntax
    end
    attr_writer :argument_syntax
    def duplicate
      Action.new( :argument_syntax => argument_syntax.to_s,
                  :method_name     => method_name,
                  :option_syntax   => option_syntax.to_blocks)
    end
    def help
      yield(o = Class.new(Hash).class_eval do
        %w(syntax).each do |m|
          define_method("on_#{m}") { |&block| self[m] = block }
          define_method("emit_#{m}") { |*a| (self[m] || default).call(*a) }
        end
        def default ; @default ||= ->(*a) { $stderr.puts(*a) } end
        self
      end.new)
      parts = [name]
      parts.push( @option_syntax ? '[generated opts]' : '[generic opts]' )
      if @argument_syntax
        parts.push @argument_syntax.to_s
      elsif @method
        parts.push '[deduced args]'
      else
        parts.push '[arguments]'
      end
      o.emit_syntax parts.join(' ')
    end
    def initialize opts
      @name = nil
      opts.each { |k, v| send("#{k}=", v) }
    end
    attr_reader :method_name
    def method_name= sym
      @method_name = sym
      @name.nil? and @name = self.class.nameize(sym)
      sym
    end
    attr_accessor :name
    attr_writer :option_syntax
    def parse argv
      @option_syntax and begin
        puts "(pretending to optparse)"
      end
      @argument_syntax and begin
        puts "(pretending to argparse #{@argument_syntax})"
      end
      return argv
    end
  end
  class ArgumentSyntax < Array
    def self.parse str
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
    def to_s
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
    def initialize
      @handlers = {}
      yield self
    end
    def invoke argv
      @runtime = Runtime.new(argv, self)
      (method, args = @runtime.parse) or return nil
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
    def parse
      @argv.empty? and return invite("Expecting #{render_actions}.")
      %w(-h --help).include?(@argv.first) and @argv[0] = 'help'
      sym = @argv.shift.intern # fuzzy match later
      action = actions.detect { |a| a.name == sym } or
        return invite("Invalid action: #{e13b sym}.\n Expecting #{render_actions}.")
      argv = action.parse(@argv) { |o| o.on_error { |e| emit(:usage, e) } } or
        return emit(:ui, "Try #{e13b "#{invocation_name} #{action.name} -h"} for help.") && nil
      [action.method_name, argv]
    end
    def render_actions
      "{#{actions.map{ |a| e13b(a.name) }.join('|')}}"
    end
  end

  module Officious ; end

  module Officious::Help
    include Styles
    extend ::Skylab::Porcelain
    option_syntax do |ctx|
      on('-a', "whatever") { ctx[:whatver] = 'x' }
      on('-b foo', "nutever") { |v| ctx[:n]  = v }
    end
    argument_syntax '[<action>]'
    def help action=nil
      action and return help_action action
      @runtime.emit(:ui, "#{header 'usage:'} #{@runtime.invocation_name} #{@runtime.render_actions} [opts] [args]")
      @runtime.emit(:ui, "For help on a particular subcommand, try #{e13b "#{@runtime.invocation_name} <subcommand> -h"}.")
    end
    def help_action action
      action == '-h' and action = 'help'
      act = self.class.actions[action.intern]
      act ||= actions.include?(action) && Action.new(:name => action, :method => method(action))
      act or return @runtime.emit(:error, "No such action #{e13b "\"#{action}\""}.  " <<
        "Try #{e13b @runtime.invocation_name} #{@runtime.render_actions} #{e13b "-h"}.")
      act.help do |o|
        o.on_syntax { |e| @runtime.emit(:payload, "#{header 'syntax:'} #{e13b "#{@runtime.invocation_name} #{e}"}") }
      end
    end
    private :help_action
  end
end

