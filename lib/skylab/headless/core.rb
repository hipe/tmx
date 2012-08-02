module Skylab end
module Skylab::Headless
  module Parameter end
  module Parameter::Definer end
  module Parameter::Definer::ModuleMethods
    def param name, meta
      parameters.fetch!(name).merge!(meta)
    end
    def parameters &block
      if block_given?
        (@parametersf ||= nil) and fail('no')
        (@parameters ||= nil) and fail('no')
        @parametersf = block
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
        if mods.any?
          mods.reverse.each { |mod| p.merge!(mod.parameters) }
        end
        if (@parametersf ||= nil)
          @parameters = p # ick
          instance_exec(&@parametersf)
          @parametersf = nil
        end
        p
      end
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
    end
    def fetch! k
      unless idx = @hash[k]
        @hash[k] = idx = list.length
        list[idx] = Parameter::Definition.new(@host, k)
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
    def label ; name end
    def merge! meta
      meta.each do |k, v| # note meta is either a arg hash or a self.class obj!
        :name == k and next
        self[k] == v and next
        self[k] = v # possibly let the below do some post processing?
        send("#{k}=", v)
      end
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
    def default= v
      has_default!
      def self.default_value ; @defaultf.call end
      @defaultf = ->{v}
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
    def set! request
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
  class Request::Runtime::Minimal < Struct.new(:build_io_adapter, :build_params)
    members.each do |builder|
      attr_writer(stem = /(?<=\Abuild_).*/.match(builder.to_s)[0].intern)
      ivar = "@#{stem}"
      define_method stem do
        instance_variable_defined?(ivar) ? instance_variable_get(ivar) :
          instance_variable_set(ivar, send(builder).call)
      end
    end
    def build_parameter_controller
      Parameter::Controller::Minimal.new(self)
    end
    def parameters
      @parameters ||= build_parameter_controller
    end
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
    def build_request_runtime
      request_runtime_class.new( ->{build_io_adapter}, ->{build_params} )
    end
    def initialize ; end # override parent-child type constructor from s.c.
    def infer_valid_action_names_from_public_instance_methods
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end
    def request_runtime ; @request_runtime ||= build_request_runtime end
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
      rescue ::OptionParser::InvalidOption => e
        return usage(e.message)
      end
      queue.empty? and enqueue!(default_action)
      last = nil
      until queue.empty?
        method = queue.shift and (last = send(method) or break)
      end
      last
    end
  protected
    attr_reader :argv
    def enqueue! method
      queue.push method
    end
    def help_string
      option_parser.to_s
    end
    def help
      emit(:help, help_string)
      true
    end
    def invite
      emit(:help, "use #{em "#{program_name} -h"} for more help")
    end
    def option_parser
      @option_parser ||= build_option_parser
    end
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
      case opcode
      when :ambiguous
        usage("cannot resolve ambiguous instream modality paradigms -- " <<
          "both STDIN and #{in_file} appear to be present.")
        nil
      when :stdin ; io_adapter.instream
      when :argv
        in_path = case argv.length
        when 0 ; suppress_normal_output? ?
                   info("No #{in_file} argument present. Done.") :
                   usage("expecting: #{in_file}")
                 nil
        when 1 ; argv.shift
        else   ; usage "expecting: #{in_file} had: (#{argv.join(' ')})"
        end
        in_path and begin
          in_path = ::Pathname.new(in_path)
          if ! in_path.exist? then usage("#{in_file} not found: #{in_path}")
          elsif in_path.directory? then usage("#{in_file} is dir: #{in_path}")
          else io_adapter.instream = in_path.open('r') # ''spot 1''
          end
        end
      end
    end
    def suppress_normal_output!
      @suppress_normal_output = true
      self
    end
    attr_reader :suppress_normal_output
    alias_method :suppress_normal_output?, :suppress_normal_output
    def usage msg
      emit(:usage, msg)
      invite
      nil # sic
    end
  end
  module CLI::Pen end
  module CLI::Pen::InstanceMethods
    MAP = { strong: 1, red: 31, green: 32 }
    def stylize str, *styles
      "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m"
    end
  end
end
