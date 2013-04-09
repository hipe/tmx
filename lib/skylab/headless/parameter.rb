module Skylab::Headless

  class Parameter  # at [#049] this might become s/thing like Formal::Parameter
                   # re-opened below
  end

  module Parameter::Definer
    class << self
      map = -> k do               # sugar, #experimental
        (map = {
          ::Class  => Parameter::Definer::InstanceMethods::IvarsAdapter,
          ::Hash   => Parameter::Definer::InstanceMethods::HashAdapter,
          ::Struct => Parameter::Definer::InstanceMethods::StructAdapter
        })[ k ]
      end

      define_method :extended do |mod| # #[#sl-111] and more .. #experimental !
        mod.extend Parameter::Definer::ModuleMethods
        mod.send :include,
          map[ ( [::Struct, ::Hash] & mod.ancestors ).fetch(0) { ::Class } ]
      end
    end
  end

  module Parameter::Definer::ModuleMethods

    def meta_param name, props=nil, &b
      parameters.meta_param! name, props, &b
    end

    def param name, props=nil, &b
      parameters.fetch!( name ).merge! props, &b
    end

    attr_reader :parameters ; alias_method :parameters_ivar, :parameters

    def parameters &block
      if block_given? # this "feature" may be removed after benchmarking (@todo)
        fail 'sanity' if parameters_f or parameters_ivar
        @parameters_f = block
        return
      end
      @parameters ||= begin
        p = Parameter::Set.new(self)
        a = ancestors
        nil until ::Object == a.pop
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
        if parameters_f
          @parameters = p # prevent inf. recursion, the below call may need this
          instance_exec(&@parameters_f)
          @parameters_f = nil
        end
        if const_defined? :PARAMS, false       # this is an ugly little
          self::PARAMS.each do |name|          # #experimental shorthand
            p.fetch!( name ).merge!( accessor: true, required: true )
          end
        end
        p
      end
    end

    attr_reader :parameters_f
  end

  module Parameter::Definer::InstanceMethods
  end

  module Parameter::Definer::InstanceMethods::HashAdapter
    def known? k
      key? k
    end                           # useless for reflection unless made public
  end

  module Parameter::Definer::InstanceMethods::StructAdapter
    def known? k
      ! self[k].nil?              # caution meet wind
    end
  end

  module Parameter::Definer::InstanceMethods::IvarsAdapter
  protected

    def [] k
      if ! instance_variable_defined? "@#{ k }"
        fail "getting without checking -- ivar not defined: @#{ k } in a #{
          self.class }"
      end
      instance_variable_get "@#{ k }"
    end

    def []= k, v
      instance_variable_set "@#{ k }", v
    end

    def known? k
      instance_variable_defined? "@#{ k }"
    end
  end

  module Parameter::Definer::InstanceMethods::ActualParametersIvar
    protected
    def []  (k)     ; @actual_parameters[k]        end
    def []= (k, v)  ; @actual_parameters[k] = v    end
    def known?(k)   ; @actual_parameters.known?(k) end
  end

  class Parameter::Definer::Dynamic < ::Hash
    extend Parameter::Definer::ModuleMethods
    def initialize
      yield self
    end
  end

  module Parameter::Definer
    def self.new &block
      k = Class.new Parameter::Definer::Dynamic
      k.class_eval(&block)
      k
    end
  end


  class Parameter::Set < MetaHell::Formal::Box

    def [] normalized_parameter_name
      @hash.fetch normalized_parameter_name do end
    end

    alias_method :known?, :has?  # this one feels ok

    def fetch! name
      if? name, -> x { x },
      -> do
        x = @host.formal_parameter_class.new @host, name
        add name, x
        x
      end
    end

    def meta_param! name, props, &b
      meta_set.fetch!( name ).merge!( props, &b )
    end

    def merge! set
      set.each do |name, param|
        fetch!( name ).merge! param
      end
      nil
    end

  protected

    def initialize host
      super( )  # init box!
      if ! host.respond_to? :formal_parameter_class
        def host.formal_parameter_class
          Parameter::DEFAULT_DEFINITION_CLASS
        end
      end
      @host = host
      @meta_set = nil
      nil
    end

    def base_args
      supr = super
      [ * supr, @host, @meta_set ]
    end

    def base_init *supr, host, meta_set
      super(* supr )
      @host = host
      @meta_set = meta_set  # .. watch out for this..
      nil
    end

    def meta_set
      @meta_set ||= begin
        # We must make our own procedurally-generated parameter definition class
        # no matter what lest we create unintentional mutations out of our
        # scope. If a formal_parameter_class has been indicated explicitly
        # otherwise, that's fine, use it as a base class here.
        fail 'sanity' if @host.const_defined? :ParameterDefinition0
        meta_host = ::Class.new @host.formal_parameter_class
        @host.const_set :ParameterDefinition0, meta_host
        @host.singleton_class.class_eval do
          remove_method :formal_parameter_class # avoid warnings, careful!
          def formal_parameter_class
            self::ParameterDefinition0
          end
        end
        meta_host.parameters
      end
    end
  end


  class Parameter  # re-opened
    # Experimentally let a formal parameter be defined as a name (symbol)
    # and an unordered set of zero or more properties, each defined as a
    # name-value pair (with Symbols for names, values as as-yet undefined.)
    # A parameter definition is always created in association with one host
    # (class or module), but in theory any existing parameter definition
    # should be able to be deep-copy applied over to to another host, or for
    # example a child class of a parent class that has parameter definitions.

    Parameter::DEFAULT_DEFINITION_CLASS = self # when the host module doesn't
                            # specify explicitly a formal_parameter_class

    # -- * -- stuff you need because you're not a hash
    include Parameter::Definer::InstanceMethods::IvarsAdapter
    def each &y
      @property_keys.each { |k| y.call(k, self[k]) }
    end
    # -- * --

    def merge! mixed, &b # might be a Hash, might be a self-class, can be nil ..
      # ..if is parameter with no properties
      mixed and mixed.each do |k, v| # is nil with a param with no hash def
        if known? k
          self[k] == v and next # do not reprocess sameval properties
        else
          @property_keys.push k
        end
        self[k] = v # do this here to kiss. inheritable property, always
        send("#{k}=", v) # possibly re-process with diffval, possibly newprop
      end
      block_given? and instance_exec(&b)
      @has_tail_queue and at_tail
      nil
    end

    def name
      @name ||= Headless::Name::Function.new @normalized_parameter_name
    end

    attr_reader :normalized_parameter_name

  protected

    # this badboy bears some explanation: so many of these method definitions
    # need the same variables to be in scope that it is tighter to define
    # them all here in this way.  Also it looks really really weird.
    # [#049] we're gonna shut this whole thing down and merge this in with
    # the way formal attributes does it.
    #
    def initialize host, name
      ::Symbol === name or fail "sjkanity - #{ host.class } for ::Symbol" # #todo
      @has_tail_queue = nil
      @property_keys = []
      class << self
        define_method_f = ->(meth, &b) { define_method(meth, &b) }
        define_method(:def!) { |meth, &b| define_method_f.call(meth, &b) }
      end
      upstream_queue = []
      def!(:apply_upstream_filter) do |host_obj, val, &final_f|
        mutated = [* upstream_queue[0..-2], ->(v, _) { final_f.call(v) } ]
        (f = ->(o, v, i=0) do
          o.instance_exec(v, ->(_v) { f[o, _v, i+1] }, &mutated[i])
        end).call(host_obj, val)
      end
      upstream_last_mutex = nil
      def!(:assert_writer) do |msg|
        upstream_last_mutex or fail("sanity check failed: #{msg}")
      end
      tail_queue = nil
      def!(:at_tail) do
        begin ; tail_queue.shift.call end while tail_queue.length.nonzero?
        tail_queue = nil
      end
      def!(:filter_upstream!) { |&node| upstream_queue.unshift node }
      upstream_f = ->(host_obj, val, i = 0) do
        host_obj.instance_exec(val,
          ->(_val) { upstream_f.call(host_obj, _val, i+1) }, &upstream_queue[i])
      end
      def!(:filter_upstream_last!) do |&node|
        upstream_last_mutex and
          fail('upstream filter endpoint can only be set once')
        upstream_queue.push(upstream_last_mutex = node)
      end
      def!(:host_def) { |meth, &b| host.send(:define_method, meth, &b) }
      def!(:on_tail) { |&b| (tail_queue ||= []).push b ; @has_tail_queue = true}
      # -- * --
      def!(:accessor=) { |_| self.reader = self.writer = true } # !!!
      def! :boolean= do |no|
        true == no and no = "not_#{name}"
        host_def("#{name}!") { self[name] = true }
        host_def("#{no}!")   { self[name] = false }
        host_def("#{name}?") { known?(name) and self[name] }
        host_def("#{no}?") { ! known?(name) || ! self[name] }
      end
      def! :builder= do |builder_f_method_name|
        host_def(name) do
          unless known?(name)
            _f = send(builder_f_method_name) or fail("no builder: #{name}")
            self[name] = _f.call
          end
          self[name]
        end
      end
      param = self
      def! :dsl= do |flags| # ( :list | :value ) [ :reader ]
        flags = [flags] if ::Symbol === flags
        list_or_value = ([:value, :list] & flags).join('').intern # ick
        reader = flags.include?(:reader)
        case list_or_value
        when :list
          list!
          filter_upstream_last! do |val, _|
            known?(name) && self[name] or self[name] = []
            self[name].push val
          end
          host_def(name, & (if reader then
            ->(*a) do
              if a.length.zero? then known?(name) ? self[name] : nil
              else a.each { |val| upstream_f.call(self, val) } end
            end
          else
            ->(v, *a) { a.unshift(v).each { |_v| upstream_f.call(self, _v) } }
          end))
        when :value
          filter_upstream_last! { |val, _| self[name] = val } # buck stops here
          host_def(name, &(if reader then
            ->(*v) do
              case v.length
              when 0 ; self[name] # trigger warnings in some implementations
              when 1 ; upstream_f.call(self, v.first)
              else   ; raise ::ArgumentError.new(
                  "wrong number of arguments (#{v.length} for 1)")
              end
            end
          else
            ->(v) { upstream_f.call(self, v) }
          end))
        else fail('no')
        end
      end
      def! :enum= do |enum|
        filter_upstream! do |val, valid_f|
          if enum.include? val
            valid_f[ val ]
          else
           _with_client do # slated to be improved [#012]
             error("#{ val.inspect } is an invalid value " <<
               "for #{ parameter_label param }")
            end
          end
        end
      end
      def! :hook= do |_|
        host_def(name) { |&b| b ? (self[name] = b) : self[name] }
      end
      def!(:reader=) { |_| host_def(name) { self[name] if known? name } }
      def!(:upstream_passthru_filter) do |&f|
        on_tail { assert_writer("passthru filter found with no writer!") }
        filter_upstream! { |val, valid_f| valid_f.call(f.call val) }
      end
      def! :writer= do |_|
        filter_upstream_last! { |val, _| self[name] = val } # buck stops here
        host_def("#{name}=") { |val| upstream_f.call(self, val) }
      end
      @normalized_parameter_name = name ; @host = host
    end
    # -- * --
    # now we use our own hands to hit ourself with our own dogfood
    extend Parameter::Definer::ModuleMethods
    def self.formal_parameter_class ; self end # during transition

    param :has_default, boolean: 'does_not_have_default'
    def default= anything
      has_default!  # defining default_value here is important, and protects us
      def!(:default_value) { anything } # defining it like so is just because
    end
    param :list, boolean: true, writer: true # define this before below line
    param :desc, dsl: [:list, :reader]       # define this after above line
    param :internal, boolean: :external, writer: true # @todo
    def pathname= _
      (host = @host).respond_to?(:pathname_class) or
        def host.pathname_class ; ::Pathname end
      on_tail { assert_writer("can't use 'pathname' without a writer") } #sanity
      upstream_passthru_filter { |v| v ? host.pathname_class.new(v.to_s) : v }
    end
    param :required, boolean: true, writer: true # @todo
  end
end
