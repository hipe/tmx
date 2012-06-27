require  File.expand_path('../..', __FILE__)
require 'skylab/pub-sub/emitter'
require 'skylab/porcelain/tite-color'
require 'skylab/porcelain/en'
require 'optparse'

module Skylab::Porcelain::Bleeding
  extend Skylab::Autoloader
  module DelegatesTo
    def delegates_to fulfiller, *methods
      methods.each { |m| define_method(m) { |*a, &b| send(fulfiller).send(m, *a, &b) } }
    end
  end
  module Styles
    include Skylab::Porcelain::En
    include Skylab::Porcelain::TiteColor
    extend self
    def em(s)  ; stylize(s, :green         )   end
    def hdr(s) ; stylize(s, :strong, :green)   end
    alias_method :pre, :em
  end
  class ActionEnumerator < Enumerator
    def filter &b
      self.class.new { |y| each { |*a| b.call(y, *a) } }
    end
    def visible
      filter { |y, a| y << a if a.visible? }
    end
  end
  EVENT_GRAPH = { :error => :all, :ambiguous => :error, :not_found => :error, :not_provided => :error,
    :syntax_error => :error, :optparse_parse_error => :error, :help => :all } # didactic
  module ActionInstanceMethods ; extend DelegatesTo
    include Styles
    alias_method :action, :class
    def action_init runtime
      @runtime = runtime
    end
    delegates_to :action, :argument_syntax
    delegates_to :action, :desc
    def emit _, *a
      @runtime.emit _, *a
    end
    def execution_method
      method :execute
    end
    def help o={}
      emit(:help, o[:message]) if o[:message]
      if o[:invite_only] then help_invite(o) ; return nil end
      help_usage o
      help_desc if o[:full]
      help_list if o[:full]
      help_invite o
      nil
    end
    def help_desc
      case desc.size
      when 0 ;
      when 1 ; emit(:help, "#{hdr 'description:'} #{desc.first}")
      else   ; emit(:help, "#{hdr 'description:'}") ; desc.each { |s| emit(:help, s) }
      end if desc
    end
    def help_invite o={}
      emit(:help, "try #{pre "#{program_name} #{action.name} -h"}#{o[:for] || ' for help'}") unless o[:full]
    end
    def help_list
      option_syntax.any? and option_syntax.help(runtime)
    end
    def help_usage o
      emit :help, "#{hdr 'usage:'} #{program_name} #{syntax}"
    end
    alias_method :initialize, :action_init
    delegates_to :action, :option_syntax
    delegates_to :runtime, :program_name
    def resolve! argv
      args = []
      ok = option_syntax.parse!(argv, args, self) or return (help unless ok.nil?)
      meth = argument_syntax.parse!(argv, args, self) or return help
      [meth, args]
    end
    attr_reader :runtime
    def syntax
      [action.name, option_syntax.string, argument_syntax.string].compact.join(' ') # duplicated
    end
  end
  OnFind = Skylab::PubSub::Emitter.new(:error, :ambiguous => :error, :not_found => :error, :not_provided => :error)
  module NamespaceInstanceMethods ; extend DelegatesTo
    include ActionInstanceMethods
    delegates_to :action, :action_syntax, :action_names, :action_helps
    def find token, &on_find_error
      e = OnFind.new(on_find_error) ; matched = [] ; action = nil
      token or return e.emit(:not_provided, "expecting #{action_syntax}")
      matcher = /^#{Regexp.escape(token)}/
      action_names.each do |act|
        first_match = act.names.grep(matcher).reduce do |_first_match, name|
          name == token and return act # first whole match always wins
          _first_match # we only want any one of these per action
        end and begin
          matched.push(first_match) ; action = act
        end
      end
      case matched.size
      when 0 ; e.emit(:not_found, "invalid command #{token.inspect}. expecting #{action_syntax}")
      when 1 ; action # fuzzy match with only one match
      else   ; e.emit(:ambiguous, "ambiguous comand #{token.inspect}. " <<
                      "did you mean #{self.or matched.map{|n| "#{pre n}"}}?") end
    end
    def help_invite o
      a, b = if o[:full] then ['<action>',   " on a particular action."]
                         else ['[<action>]'] end
      emit :help, "try #{pre "#{program_name} #{a} -h"} for help#{b}"
    end
    def help_list
      tbl = action_helps.visible.map { |action|  [action.name, (action.summary || [])] }
      emit :help, (tbl.empty? ? "(no actions)" : "#{hdr 'actions:'}")
      width = tbl.reduce(0) { |m, o| o[0].length > m ? o[0].length : m }
      fmt = "  #{em "%#{width}s"}  %s"
      fmt2 = "  #{' ' * width}  %s"
      tbl.each do |row|
        emit :help, (fmt % [row[0], row[1][0]])
        row[1].size > 1 and row[1][1..1].each { |s| emit(:help, fmt2 % [s]) }
      end
    end
    def help_usage o
      action_syntax = (false == o[:action_syntax]) ? '<action>' : self.action_syntax
      emit :help, "#{hdr 'usage:'} #{program_name} #{action_syntax} [opts] [args]"
    end
    def program_name
      "#{runtime.program_name} #{action_collection.name}" #!
    end
    def resolve! argv
      action = find(argv.shift){ |o| o.on_error { |s| return help(message: s.message, action_syntax: false) } }
      transaction = action.build self
      huh = transaction.resolve! argv
      huh
    end
  end
  class ArgumentSyntax
    def [] idx
      string.split(' ')[idx] or "<arg#{idx + 1}>"  # @hack
    end
    attr_reader :action
    def define! s
      @string = s
    end
    def initialize action
      @action = action
      @string = nil
    end
    def parse! argv, args, transaction
      meth = transaction.execution_method
      parameters = meth.parameters
      transaction.option_syntax.any? and parameters.pop # ick
      count = Hash.new { |h, k| h[k] = 0 }
      parameters.each { |p| count[p.first] += 1 }
      error = ->(msg) { transaction.runtime.emit(:syntax_error, msg) ; false }
      requireds = ->(i) { parameters.select{ |p| :req == p.first }[i].last }
      min_arity = count[:req]
      max_arity = count.values.reduce(:+) if count[:rest].zero?
      argv.size < min_arity and return error["missing argument: #{requireds[argv.size]}"]
      argv.size > max_arity and return error["unexpected argument: #{argv[max_arity]}"] if max_arity
      args[0, 0] = argv
      argv.clear
      meth
    end
    def string
      @string and return @string
      params = action.parameters
      action.option_syntax.any? and params.pop
      params.map do |p|
        a, b = case p.first
               when :req  ;
               when :opt  ; %w([ ])
               when :rest ; %w([ [..]])
               else       ; fail("not expecting this token: #{p.first.inspect}")
               end
        "#{a}<#{p.last}>#{b}"
      end.join(' ')
    end
  end
  class OptionSyntax < Struct.new(:definitions, :documentor_class, :parser_class, :help_enabled)
    include Styles
    def any?
      definitions.any?
    end
    def on_definition_added
      @on_definition_added ||= {}
    end
    def define! &b
      definitions.push b
      on_definition_added.each { |_, l| instance_exec(&l) }
    end
    def documentor
      @documentor ||= documentor_class.new.tap { |d| init_documentor(d) }
    end
    def help e
      one_big_string = documentor.help { |line| e.emit(:help, line) } and e.emit(:help, one_big_string)
    end
    def init_documentor doc
      on_definition_added[:documentor] ||= ->() { @documentor = nil ; $stderr.puts("NEATO!") }
      doc.banner = "#{hdr 'options:'}"
      _ = {} ; definitions.each { |d| doc.instance_exec(_, &d) }
    end
    def initialize
      super([], ::OptionParser, ::OptionParser)
      @documentor = nil
    end
    def parse! argv, args, transaction
      definitions.any? or help_enabled or return true
      args.push(req = {}) if definitions.any?
      ret = true
      begin
        parser_class.new do |o|
          o.on('-h', '--help') do
            transaction.help(full: true)
            ret = nil
          end
          definitions.each { |d| o.instance_exec(req, &d) }
        end.parse!(argv)
      rescue OptionParser::ParseError => e
        transaction.runtime.emit :optparse_parse_error, e
        ret and ret = false # if ret was already nil, no need to display help again
      end
      ret
    end
    def string
      definitions.empty? and return nil
      documentor.instance_variable_get('@stack')[2].instance_variable_get('@list'). # less hacky is out of scope
        map { |s| "[#{s.short.first or s.long.first}#{s.arg}]" if s.respond_to?(:short) }.compact.join(' ')
    end
  end
  module ActionModuleMethods
    include Styles
    def action_name
      @action_name ||= to_s.match(/[^:]+$/)[0].gsub(/(?<=[a-z])([A-Z])/) { "-#{$1}" }.downcase
    end
    def aliases *a
      @aliases ||= []
      a.any? ? @aliases.concat(a) : @aliases
    end
    def argument_syntax s=nil
      @argument_syntax ||= ArgumentSyntax.new(self)
      s ? @argument_syntax.define!(s) : @argument_syntax
    end
    def build runtime
      new runtime
    end
    def desc *a
      a.size.zero? ? (@desc ||= nil) : (@desc ||= []).concat(a)
    end
    def name
      action_name # allows more flexibility than an alias_method
    end
    def names
      [name, *aliases]
    end
    def option_syntax &b
      @option_syntax ||= option_syntax_class.new
      b ? @option_syntax.define!(&b) : @option_syntax
    end
    def option_syntax_class klass=nil
      klass or return OptionSyntax
      redefine = ->(mod, k2) do
        mod.singleton_class.send(:define_method, :option_syntax_class) { |k3 = nil| k3 ? redefine[self, k3] : k2 }
      end
      redefine.call(self, klass)
    end
    def parameters
      instance_method(:execute).parameters
    end
    def summary &b
      if b                     ; @summary = b
      elsif (@summary ||= nil) ; instance_eval(&@summary)
      elsif desc               ; desc[0..2] end
    end
    def syntax
      [action_name, option_syntax.string, argument_syntax.string].compact.join(' ') # duplicated
    end
    def visible *a
      instance_variable_defined?('@visible') or @visible = true
      case a.length ; when 0 ; @visible ; when 1 ; @visible = a.first ; else fail end
    end
    attr_writer :visible
    alias_method :visible?, :visible
  end
  module Action
    def self.extended mod
      mod.send :include, ActionInstanceMethods
      mod.send :extend, ActionModuleMethods
    end
  end
  module Namespace
    include ActionModuleMethods
    def action_collections
      [ action_collection, OfficiousActions ]
    end
    def action_collection
      self
    end
    def action_syntax
      "{#{ action_names.visible.map { |a| pre a.name } * '|' }}"
    end
    def action_helps  ; enum :action_helps ; end
    def action_names  ; enum :action_names ; end
        # there is an anticpated issue above with fuzzy matching actions that have same name in different module
    def enum method
      (@enum ||= Hash.new do |hash, meth|
        hash[meth] = ActionEnumerator.new do |y|
          action_collections.each do |col|
            if col != self and col.respond_to?(meth)
              col.send(meth).each { |x| y << x }
            elsif col.respond_to?(:constants)
              col.constants.each { |k| y << col.const_get(k) }
            else
              fail("expected action collection to respond to `#{meth}`, `each`, or `constants`: #{col}")
            end
          end
        end
      end)[method]
    end
    def build runtime
      NamespaceAction.new(self, runtime)
    end
    def parameters
      NamespaceAction.parameters
    end
    alias_method :orig_summary, :summary
    def summary &b
      b || desc || @summary and return orig_summary(&b)
      aa = action_names.visible.to_a
      ["child action#{'s' if aa.size != 1}: {#{build(nil).action_names.visible.map{ |a| "#{pre a.name}" }.join('|')}}"]
    end
  end
  class NamespaceAction ; extend DelegatesTo
    extend Action
    include NamespaceInstanceMethods
    delegates_to :action_collection, :action_syntax, :action_names
    attr_reader :action_collection
    delegates_to :action_collection, :desc
    def initialize namespace, runtime
      action_init runtime
      @action_collection = namespace
    end
    delegates_to :action_collection, :name
  end
  class Runtime
    extend Namespace
    include NamespaceInstanceMethods
    def action_collection
      action.action_collection
    end
    def emit _, s
      $stderr.puts s
    end
    def initialize
    end
    def invoke argv
      argv = argv.dup
      (callable, args = resolve!(argv)) or return callable
      callable.receiver.send(callable.name, *args)
    end
    def program_name
      (@program_name ||= nil) || File.basename($PROGRAM_NAME)
    end
    attr_writer :program_name
  end
  class << Runtime
    def action_collection *a, &b
      case a.length
      when 0 ; if b then @action_collection = b
             ; else (@action_collection ||= ->(){ const_get('Actions') }).call end
      when 1 ; if b then fail else mod = a.first ; @action_collection = ->() { mod } end
      else   ; fail ; end
    end
    alias_method :action_collection=, :action_collection # !
  end
  module OfficiousActions
  end
  class OfficiousActions::Help
    extend Action

    aliases '-h'

    desc "displays this screen."

    visible false

    def action_help action_name
      action = runtime.find(action_name) do |o|
        o.on_error do |e|
          return emit(:error, e.message)
        end
      end
      action.build(runtime).help(full: true)
      nil
    end

    def execute action_name=nil
      action_name ? action_help(action_name) : runtime.help(full: true)
    end
  end
end

