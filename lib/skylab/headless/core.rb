module Skylab end
module Skylab::Headless
  module Parameter end
  module Parameter::Definer end
  module Parameter::Definer::ModuleMethods
    def param name, meta=nil, &b
      parameters.fetch!(name).merge!(meta, &b)
    end
    def parameters &block
      if block_given?
        (@parameters_f ||= nil) || (@parameters ||= nil) and fail('no')
        @parameters_f = block
        return
      end
      @parameters ||= begin
        p = Parameter::Set.new(self)
        a = ancestors
        nil until ::Object == (m = a.pop)
        self == a[0] and a.shift
        mods = [] ; klass = nil
        a.each do |mod|
          mod.respond_to?(:parameters) or next
          if ::Class === mod
            ! klass and mods.push(klass = mod)
          else
            ! (klass && klass.ancestors.include?(mod)) and mods.push(mod)
          end
        end
        mods.reverse.each { |mod| p.merge!(mod.parameters) }
        if (@parameters_f ||= nil)
          @parameters = p # prevent inf. recursion, the below call may need this
          instance_exec(&@parameters_f)
          @parameters_f = nil
        end
        p
      end
    end
  end
  module Parameter::Definer::InstanceMethods
    # these are typically for if you are not a Struct or Hash
  protected
    def [](k) ; instance_variable_get("@#{k}") end
    def []=(k, v) ; instance_variable_set("@#{k}", v) end
  end
  class Parameter::Definer::Dynamic < ::Hash
    extend Parameter::Definer::ModuleMethods
    def initialize &block
      block.call self
    end
  end
  module Parameter::Definer
    def self.new &block
      k = Class.new Parameter::Definer::Dynamic
      k.class_eval(&block)
      k
    end
  end
  class Parameter::Set < Struct.new(:list)
    attr_reader :host
    def [] name
      (idx = @hash[name]) ? list[idx] : nil
    end
    def initialize host
      super([])
      @hash = {}
      @host = host
      host.respond_to?(:parameter_definition_class) or
        def host.parameter_definition_class ; Parameter::Definition end
    end
    def fetch! k
      unless idx = @hash[k]
        @hash[k] = idx = list.length
        list[idx] = @host.parameter_definition_class.new(@host, k)
      end
      list[idx]
    end
    def merge! set
      set.list.each do |o|
        fetch!(o.name).merge!(o)
      end
      nil
    end
  end

  class Parameter::Definition_
    # Experimentally let a parameter definition be defined as a name (symbol)
    # and an unordered set of zero or more properties, each defined as a
    # name-value pair (with Symbols for names, values as as-yes undefined.)
    # A parameter definition is always created in association with one host
    # (class or module), but in theory any existing parameter definition
    # should be able to be deep-copy applied over to to another host, or for
    # example a child class of a parent class that has parameter definitions.
    # It is then useful (maybe?) to keep this surface representation of a
    # parameter definition as a hash as an aid in future such reflection
    # and re-application (but this may change!)

    include Parameter::Definer::InstanceMethods

    def merge! mixed # might be a Hash, might be a self-class, .. other? ..
      block_given? and fail('huh?') # .. also it is an override
      mixed.each do |k, v|
        self[k] == v and next # do not reprocess sameval properties
        send("#{k}=", v) # possibly re-process with diffval, possibly newprop
      end
      nil
    end

  protected

    # this badboy bears some explanation: so many of these method definitions
    # need the same variables to be in scope that it is tighter to define
    # them all there in this way.  Also it looks really really weird.
    def initialize host, name
      sc = class << self
        class << self ; alias_method :def, :define_method ; public :def ; end
        self
      end
      sc.def(:def!) { |meth, &b| sc.def(meth, &b) }
      def!(:host_def) { |meth, &b| host.send(:define_method, meth, &b) }
      # -- * --
      def!(:accessor=) { |_| self.reader = self.writer = true } # !!!
      def! :boolean= do |no|
        true == no and no = "not_#{name}"
        host_def("#{name}!") { self[name] = true }
        host_def("#{no}!")   { self[name] = false }
        host_def("#{name}?") { self[name] }
        host_def("#{no}?") { ! self[name] }
      end
      def! :hook= do |_|
        host_def(name) { |&b| b ? (self[name] = b) : self[name] }
      end
      def!(:reader=) { |_| host_def(name) { self[name] } }
      def!(:writer=) { |_| host_def("#{name}=") { |v| self[name] = v } }
    end
  end

  class Parameter::Definition < Hash
    extend Parameter::Definer::ModuleMethods
    def define_method name, &block
      host.send(:define_method, name, &block)
    end
    attr_reader :host
    def initialize host, name
      self[:name] = name
      @host = host
    end
    def merge! meta=nil, &b
      meta.each do |k, v| # note meta is either a arg hash or a self.class obj!
        :name == k and next
        self[k] == v and next
        self[k] = v # possibly let the below do some post processing?
        send("#{k}=", v)
      end if meta
      block_given? and instance_exec(&b) # *very* experimental
      nil
    end
    def name
      self[:name] # this line of code is the center of the universe
    end
    def param_reader
      name = self.name
      define_method(name) { self[name] }
    end
    def param_writer
      name = self.name
      define_method("#{name}=") { |v| self[name] =v }
    end
    # -- * --
    def accessor= _
      param_reader
      param_writer
    end
    def boolean= no=true
      name = self.name
      true == no and no = "not_#{name}"
      define_method("#{name}!") { self[name] = true }
      define_method("#{no}!") { self[name] = false }
      define_method("#{name}?") { self[name] }
      define_method("#{no}?") { ! self[name] }
      define_method("#{name}=") { |v| self[name] = v }
    end
    def builder= builder_lambda_method
      name = self.name
      define_method(name) do
        o = super() and return o
        send("#{name}=", send(builder_lambda_method).call)
      end
    end
    def default= v
      has_default!
      def self.default_value ; @defaultf.call end
      @defaultf = ->{v}
    end
    def desc *a
      a.empty? ? self[:desc] : (self[:desc] ||= []).concat(a.flatten)
    end
    def enum= enum
      self[:enum] = enum
      param_reader
      name = self.name
      define_method("#{name}=") do |v|
        if (p = _formal_parameters[name]).enum.include?(v)
          self[name] = v
        else
          _client do
            error("#{v.inspect} is an invalid value for #{em p.label}.")
          end
        end
      end
    end
    def hook= _
      name = self.name
      define_method(name) { |&b| b ? (self[name] = b ; self) : self[name] }
    end
    def label ; name.to_s.gsub('_', '-') end
    def pathname= _
      name = self.name
      define_method("#{name}=") do |v|
        v and String === v and v = ::Pathname.new(v) # not sure
        self[name] = v
      end
      param_reader
    end
    def reader= _
      param_reader
    end
    def writer= _
      param_writer
    end
    # --- * ---
    param :enum, reader: true
    param :getter, accessor: true
    param :has_default, boolean: :does_not_have_default
    param :internal, boolean: :external
    param :required, boolean: true
  end

  module Parameter::Controller end
  module Parameter::Controller::InstanceMethods
    # and_ em error errors_count formal_parameters params s
    def defaults request
      fp = formal_parameters
      pks = request.keys ; dks = fp.list.select(&:has_default?).map(&:name)
      request.merge!  Hash[ (dks - pks).map { |k| [k, fp[k].default_value] } ]
      nil
    end
    def errors_count ; request_runtime.errors_count end
    def formal_parameters ; params.class.parameters end # !
    def missing_required
      a = formal_parameters.list.select(&:required?).reduce([]) do |m, p|
        m << p if params[p.name].nil? ; m
      end.map { |o| em o.label }
      a.any? and error("missing the required parameter#{s a} #{and_ a}")
    end
    def prune_bad_keys request # internal defaults may exist hence ..
      notpar = intern = nil ; formal = formal_parameters
      request.keys.each do |k|
        ok = false
        if ! (param = formal[k]) then (notpar ||= []).push(k)
        elsif param.internal?    then (intern ||= []).push(param.label)
        else ok = true
        end
        ok or request.delete(k) # for aggregation of errors (non-atomic)
      end
      notpar and notpar.map! { |l| em l }
      intern and intern.map! { |l| em l }
      notpar and error("#{and_ notpar} #{s :is} not #{s :a}parameter#{s}")
      intern and error("#{and_ intern} #{s :is} #{s :an}internal parameter#{s}")
    end
    def set! request=nil
      errors_count_before = errors_count
      prune_bad_keys(request = request ? request.dup : {})
      defaults request
      request.each do |k, v|
        if ! params.respond_to?(meth = "#{k}=")
          error("not writable: #{k}")
        else
          params.send(meth, v) # not atomic w/ all of above as es muss sein
        end
      end
      missing_required
      errors_count_before == errors_count
    end
  end

  module Request end
  module Request::Runtime end
  class Request::Runtime::Minimal < Struct.new(
    :io_adapter_f, :params_f, :parameter_controller_f,
    :io_adapter,   :params,   :parameter_controller
  )
    extend Parameter::Definer::ModuleMethods
    def errors_count ; io_adapter.errors_count end # *very* experimental here
    param :io_adapter,           builder: :io_adapter_f
    param :params,               builder: :params_f
    param :parameter_controller, builder: :parameter_controller_f
  end

  module SubClient end
  module SubClient::InstanceMethods
    def emit(*a) ; io_adapter.emit(*a) end
    def error(s) ; emit(:error, s) ; false end
    def initialize(r) ; self.request_runtime = r end
    def io_adapter ; request_runtime.io_adapter end
    def params ; request_runtime.params end
    attr_accessor :request_runtime
    # --- * ---
    def em s ; io_adapter.pen.em s end
    # --- * ---
    THE_ENGLISH_LANGUAGE = # @id: 6
      { a: ['a '], an: ['an '], is: ['is', 'are'], s:[nil, 's'] }
    def and_ a, last = ' and ', sep = ', '
      @_coun = ::Fixnum === a ? a : a.length
      (hsh = Hash.new(sep))[a.length - 1] = last
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end

    def s count=nil, part=nil
      args = [count, part].compact
      part = ::Symbol === args.last ? args.pop : :s
      coun = 1 == args.length ? args.pop : @_coun
      @_coun = ::Fixnum === coun ? coun : coun.length # gigo
      THE_ENGLISH_LANGUAGE[part][1 == @_coun ? 0 : 1]
    end
  end

  class Parameter::Controller::Minimal
    include Parameter::Controller::InstanceMethods
    include SubClient::InstanceMethods
  end

  module Client end
  module Client::InstanceMethods
    include SubClient::InstanceMethods
    def build_parameter_controller
      Parameter::Controller::Minimal.new(request_runtime)
    end
    def build_params
      params_class.new
    end
    def build_request_runtime
      request_runtime_class.new(
        ->{build_io_adapter}, ->{build_params}, ->{build_parameter_controller}
      )
    end
    def initialize ; end # override parent-child type constructor from s.c.
    def infer_valid_action_names_from_public_instance_methods
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end
    def parameters ; request_runtime.parameter_controller end # *very* experimental!
    def request_runtime ; @request_runtime ||= build_request_runtime end
    def request_runtime_class ; Request::Runtime::Minimal end
  end
  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/

  module API end
  module API::InstanceMethods
    include Client::InstanceMethods
    def invoke meth, params=nil
      API::Promise.new do
        response do
          if ! valid_action_names.include?(meth)
            error("cannot #{meth}")
          elsif result = send(meth, *[params].compact)
            true == result or emit(:payload, result)
          end
        end
      end
    end
  protected
    def build_runtime_error
      runtime_error_class.new(request_runtime.io_adapter.errors.join('; '))
    end
    def response
      yield # caller must handle return value processing of client method
      if (io = request_runtime.io_adapter).errors.empty?
        io.payloads.length > 1 ? io.payloads : io.payloads.first # look
      else
        raise build_runtime_error
      end
    end
    def runtime_error_class ; API::RuntimeError end
  end

  class API::Promise < ::BasicObject # thanks Ben Lavender
    NOT_SET = ::Object.new
    def initialize &b
      @block = b
      @result = NOT_SET
    end
    def method_missing *a, &b
      __result__.send(*a, &b)
    end
    def __result__
      NOT_SET == @result and @result = @block.call
      @result
    end
  end

  class API::RuntimeError < ::RuntimeError ; end

  module CLI end
  module CLI::InstanceMethods
    include Client::InstanceMethods
    def invoke argv
      @argv = argv
      (@queue ||= []).clear
      begin
        option_parser.parse! argv
      rescue ::OptionParser::ParseError => e
        usage e.message
        return exit_status_for(:parse_opts_failed)
      end
      queue.empty? and enqueue! default_action
      result = nil
      until queue.empty?
        if m = queue.first # implementations may use (meaningful) empty opcodes
          if m.respond_to?(:call)
            result = m.call or break
          elsif a = parse_argv_for(m)
            result = send(m, *a) or break
          else
            result = exit_status_for(:parse_argv_failed)
            break
          end
        end
        queue.shift
      end
      result
    end
  protected
    attr_reader :argv
    def argument_syntax_for m
      @argument_syntax = # ''hazy''
      (@argument_syntaxes ||= {})[m] ||= build_argument_syntax_for(m)
    end
    def argument_syntax_string
      (@argument_syntax ||= nil) or argument_syntax_for(default_action)
      @argument_syntax.string # ''hazy''
    end
    def build_argument_syntax_for m
      CLI::ArgumentSyntax::Inferred.new(method(m).parameters,
        respond_to?(:formal_paramaters) ? formal_parameters : nil)
    end
    def build_io_adapter
      io_adapter_class.new $stdin, $stdout, $stderr, build_pen
    end
    def build_pen
      pen_class.new
    end
    def enqueue! method
      queue.push method
    end
    def exit_status_for sym
    end
    def help_string
      option_parser.to_s
    end
    def help
      emit(:help, help_string)
      true
    end
    def in_file
      "<#{argument_syntax_for(queue.first).first.label}>"
    end
    def invite
      emit(:help, "use #{em "#{program_name} -h"} for more help")
    end
    def io_adapter_class
      CLI::IO::Adapter::Minimal
    end
    def option_parser
      @option_parser ||= build_option_parser
    end
    def option_syntax_string
      (@option_parser ||= nil) or return nil
      @option_parser.top.list.map do |s|
        "[#{s.short.first or s.long.first}#{s.arg}]" if s.respond_to?(:short)
      end.compact.join(' ') # stolen and improved from Bleeding @todo
    end
    def parse_argv_for m
      argument_syntax_for(m).parse_argv(argv) do |o|
        o.on_unexpected do |a|
          usage("unexpected argument#{s a}: #{a[0].inspect}#{
            " [..]" if a.length > 1}") && nil
        end
        o.on_missing do |fragment|
          fragment = fragment[0..fragment.index{ |p| :req == p[:opt_req_rest] }]
          usage("expecting: #{em fragment.string}") && nil
        end
      end
    end
    def pen_class ; CLI::IO::Pen::Minimal end
    def program_name
      (@program_name ||= nil) || ::File.basename($PROGRAM_NAME)
    end
    attr_writer :program_name
    attr_reader :queue
    # its location here is experimental. note it may open a filehandle.
    def resolve_instream
      stdin = io_adapter.instream.tty? ? :tty : :stdin
      no_argv = argv.empty? ? :no_argv : :argv
      opcode =
      case [stdin, no_argv]
      when [:tty, :argv], [:tty, :no_argv] ; :argv
      when [:stdin, :argv]                 ; :ambiguous
      when [:stdin, :no_argv]              ; :stdin
      end
      result = nil
      case opcode
      when :ambiguous
        usage("cannot resolve ambiguous instream modality paradigms -- " <<
          "both STDIN and #{in_file} appear to be present.")
      when :stdin ; result = io_adapter.instream
      when :argv
        in_path = nil
        case argv.length
        when 0 ; suppress_normal_output? ?
                   info("No #{in_file} argument present. Done.") :
                   usage("expecting: #{in_file}")
        when 1 ; in_path = argv.shift
        else   ; usage("expecting: #{in_file} had: (#{argv.join(' ')})")
        end
        in_path and begin
          in_path = ::Pathname.new(in_path)
          if ! in_path.exist? then usage("#{in_file} not found: #{in_path}")
          elsif in_path.directory? then usage("#{in_file} is dir: #{in_path}")
          else result = io_adapter.instream = in_path.open('r') # ''spot 1''
          end
        end
      end
      result
    end
    def suppress_normal_output!
      @suppress_normal_output = true
      self
    end
    attr_reader :suppress_normal_output
    alias_method :suppress_normal_output?, :suppress_normal_output
    def usage msg=nil
      emit(:usage, msg) if msg
      emit(:usage, usage_line)
      invite
      nil # return value undefined, but client might override and do otherwise
    end
    def usage_line
      "#{em('usage:')} #{usage_syntax_string}"
    end
    def usage_syntax_string
      [program_name, option_syntax_string, argument_syntax_string].compact * ' '
    end
  end

  module CLI::ArgumentSyntax end
  class CLI::ArgumentSyntax::Inferred < ::Array
    def initialize method_parameters, formal_parameters
      formal_parameters ||= {}
      formal_method_parameters = method_parameters.map do |opt_req_rest, name|
        p = formal_parameters[name] || Parameter::Definition.new(nil, name)
        p[:opt_req_rest] ||= opt_req_rest # maybe mutuates class property!
        p
      end
      concat formal_method_parameters
    end
    def parse_argv argv, &events
      hooks = Parameter::Definer.new do
        param :on_missing, hook: true
        param :on_unexpected, hook: true
      end.new(&events)
      formal = dup
      actual = argv.dup
      result = argv
      while ! actual.empty?
        if formal.empty?
          result = hooks.on_unexpected.call(actual)
          break
        elsif idx = formal.index { |f| :req == f[:opt_req_rest] }
          actual.shift # knock these off l to r always
          formal[idx] = nil # knock the leftmost required off
          formal.compact!
        elsif :rest == formal.first[:opt_req_rest]
          break
        elsif # assume first is :opt and no required exist
          formal.shift
          actual.shift
        end
      end
      if formal.detect { |p| :req == p[:opt_req_rest] }
        result = hooks.on_missing.call(formal)
      end
      result
    end
    def string
      map do |p|
        case p[:opt_req_rest]
        when :opt  ; "[<#{p.label}>]"
        when :req  ; "<#{p.label}>"
        when :rest ; "[<#{p.label}> [..]]"
        end
      end.join(' ')
    end
  end

  module CLI::IO end
  module CLI::IO::Adapter end
  class CLI::IO::Adapter::Minimal <
    ::Struct.new(:instream, :outstream, :errstream, :pen)
    def emit type, msg
      send( :payload == type ? :outstream : :errstream ).puts msg
      nil # undefined
    end
  end

  module CLI::IO::Pen end
  module CLI::IO::Pen::InstanceMethods
    MAP = ::Hash[ [[:strong, 1]].
      concat [:dark_red, :green, :yellow, :blue, :purple, :cyan, :white, :red].
        each.with_index.map { |v, i| [v, i+31] } ]
    def stylize str, *styles
      "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m"
    end
    def unstylize str # nil if string is not stylized
      str.dup.gsub!(/\e\[\d+(?:;\d+)*m/, '')
    end
  end

  class CLI::IO::Pen::Minimal
    include CLI::IO::Pen::InstanceMethods
    def em s ; stylize(s, :strong, :green) end
  end
end
