module Skylab::Fields

  class Parameter  # *read* [#009]

    class << self

      def _same mod, * x_a
        Bundles__.edit_module_via_mutable_iambic mod, x_a
      end

      alias_method :[], :_same
      alias_method :call, :_same
    end  # >>

    module Bundles__

      Oldschool_parameter_error_structure_handler = -> _ do
        private
        def parameter_error_structure ev
          _msg = instance_exec( * ev.to_a, & ev.message_proc )
          send_error_string _msg
        end
      end

      Parameter_controller = -> a do
        module_exec a, & Here_::Controller__.to_proc
      end

      Parameter_controller_struct_adapter = -> a do
        module_exec a, & Here_::Controller__::Struct_Adapter.to_proc
      end

      Home_.lib_.plugin::Bundle::Multiset[ self ]
    end

    Definer = -> mod do

      mod.extend Definer_Module_Methods

      _mod_ = if mod.method_defined? :keys
        Hash_Adapter_Methods___

      elsif mod.method_defined? :members
        Struct_Adapter_Methods

      else
        Ivars_Adapter_Methods
      end

      mod.include _mod_

      NIL_
    end

    # <-

    module Definer_Module_Methods  # :+#public-API ([tm])

      attr_reader :parameters_p

    def meta_param name, props=nil, &b
      parameters.meta_param! name, props, &b
    end

    def param name, props=nil, &b
      parameters.fetch!( name ).merge! props, &b
    end

      attr_reader :parameters
      alias_method :any_parameters, :parameters

      def parameters
        @parameters ||= __build_parameters
      end

      def __build_parameters
        p = Set___.new self
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
        if parameters_p
          @parameters = p # prevent inf. recursion, the below call may need this
          instance_exec(&@parameters_p)
          @parameters_p = nil
        end
        if const_defined? :PARAMS, false       # this is an ugly little
          self::PARAMS.each do |name|          # #experimental shorthand
            p.fetch!( name ).merge!( accessor: true, required: true )
          end
        end
        p
      end
    end

  module Hash_Adapter_Methods___
    def known? k
      key? k
    end                           # useless for reflection unless made public
  end

  module Struct_Adapter_Methods  # :+#public-API [tm]
    def known? k
      ! self[k].nil?              # caution meet wind
    end
  end

  module Ivars_Adapter_Methods  # :+#public-API [tm]
  protected  # #protected-not-private

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

    # ~ conveninence maker for hash-based parameters structure [hl]

    def Definer.new & edit_p
      cls = ::Class.new Dynamic_Definer___
      cls.class_exec( & edit_p )
      cls
    end

    class Dynamic_Definer___ < ::Hash

      extend Definer_Module_Methods

      def initialize
        yield self
      end
    end

    # ~ internal support (models)

  class Set___

    def initialize host
      host.respond_to? :formal_parameter_class or
        def host.formal_parameter_class
          DEFAULT_DEFINITION_CLASS___
        end
      @meta_set = nil ; @host = host
      @bx = Callback_::Box.new
    end

    def has? k
      @bx.has_name k
    end

    def get_names
      @bx.get_names
    end

    def to_a
      @bx.to_enum( :each_value ).to_a
    end

    def each_name & p
      if p
        @bx.each_name( & p )
      else
        @bx.to_enum :each_name
      end
    end

    def each_value( & p )
      if p
        @bx.each_value( & p )
      else
        @bx.to_enum :each_value
      end
    end

    def each_pair( & p )
      if p
        @bx.each_pair( & p )
      else
        @bx.to_enum :each_pair
      end
    end

    def [] normalized_parameter_name
      @bx[ normalized_parameter_name ]
    end

    def fetch k, & p
      @bx.fetch k, & p
    end

    def fetch! name
      @bx.touch name do
        @host.formal_parameter_class.new @host, name
      end
    end

    def merge! set
      set.each_pair do |name, param|
        fetch!( name ).merge! param
      end ; nil
    end

    def meta_param! name, props, &b
      meta_set.fetch!( name ).merge!( props, &b )
    end
  private
    def meta_set
      @meta_set ||= bld_meta_set
    end
    def bld_meta_set  # #storypoint-220
      @host.const_defined?( :ParameterDefinition0 ) and self._sanity_
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
  # ->
  end

  # ~ as class

  class Parameter  # re-opened, #storypoint-230

    # -- * -- stuff you need because you're not a hash

    include Ivars_Adapter_Methods

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
      @name ||= Callback_::Name.via_variegated_symbol @normalized_parameter_name
    end

    attr_reader :normalized_parameter_name

    def reader_method_name
      @normalized_parameter_name
    end

    def writer_method_name
      @writer_method_name ||= :"#{ @normalized_parameter_name }="
    end

  private

    def initialize host, name  # #storypoint-280
      @has_tail_queue = nil
      @property_keys = []
      class << self
        define_method_p = ->(meth, &b) { define_method(meth, &b) }
        define_method(:def!) { |meth, &b| define_method_p.call(meth, &b) }
      end
      upstream_queue = []
      def!(:apply_upstream_filter) do |host_obj, val, &final_p|
        mutated = [* upstream_queue[0..-2], ->(v, _) { final_p.call(v) } ]
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
      upstream_p = ->(host_obj, val, i = 0) do
        host_obj.instance_exec(val,
          ->(_val) { upstream_p.call(host_obj, _val, i+1) }, &upstream_queue[i])
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
            _p = send(builder_f_method_name) or fail("no builder: #{name}")
            self[name] = _p.call
          end
          self[name]
        end
      end
      param = self
      def! :dsl= do |flags| # ( :list | :value ) [ :reader ]
        flags = [flags] if ::Symbol === flags
        list_or_value = ( %i( value list ) & flags ).
          join( EMPTY_S_ ).intern  # ick
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
              else a.each { |val| upstream_p.call(self, val) } end
            end
          else
            ->(v, *a) { a.unshift(v).each { |_v| upstream_p.call(self, _v) } }
          end))
        when :value
          filter_upstream_last! { |val, _| self[name] = val } # buck stops here
          host_def(name, &(if reader then
            ->(*v) do
              case v.length
              when 0 ; self[name] # trigger warnings in some implementations
              when 1 ; upstream_p.call(self, v.first)
              else   ; raise ::ArgumentError.new(
                  "wrong number of arguments (#{v.length} for 1)")
              end
            end
          else
            ->(v) { upstream_p.call(self, v) }
          end))
        else fail('no')
        end
      end
      def! :enum= do |enum|
        filter_upstream! do |val, valid_p|
          if enum.include? val
            valid_p[ val ]
          else
           _with_client do  # slated to be improved [#012]
             send_error_string "#{ val.inspect } is an invalid value #{
               }for #{ parameter_label param }"
            end
          end
        end
      end
      def! :hook= do |_|
        host_def name do | *a, &p |
          case ( p ? a <<  p : a ).length
          when 0 ; self[ name ]
          when 1 ; self[ name ] = a[ 0 ]
          else   ; raise ::ArgumentError, "no - (#{ a.length } for 0..1)"
          end
        end
      end
      def!(:reader=) { |_| host_def(name) { self[name] if known? name } }
      def!(:upstream_passthru_filter) do |&f|
        on_tail { assert_writer("passthru filter found with no writer!") }
        filter_upstream! { |val, valid_p| valid_p.call(f.call val) }
      end
      def! :writer= do |_|
        filter_upstream_last! { |val, _| self[name] = val } # buck stops here
        host_def("#{name}=") { |val| upstream_p.call(self, val) }
      end
      @normalized_parameter_name = name ; @host = host
    end

    DEFAULT_DEFINITION_CLASS___ = self
      # when the host module doesn't specify explicitly a formal_parameter_class

    EMPTY_S_ = ' '

    Here_ = self


    # -- * --
    # now we use our own hands to hit ourself with our own dogfood

    extend Definer_Module_Methods

    def self.formal_parameter_class ; self end # during transition

    param :has_default, boolean: 'does_not_have_default'

    def default= anything
      has_default!  # defining default_value here is important, and protects us
      def!(:default_value) { anything } # defining it like so is just because
    end

    param :list, boolean: true, writer: true # define this before below line

    param :desc, dsl: [:list, :reader]       # define this after above line

    param :internal, boolean: :external, writer: true

    def pathname= _
      (host = @host).respond_to?(:pathname_class) or
        def host.pathname_class ; ::Pathname end
      on_tail { assert_writer("can't use 'pathname' without a writer") } #sanity
      upstream_passthru_filter { |v| v ? host.pathname_class.new(v.to_s) : v }
    end

    param :required, boolean: true, writer: true
  end
end

# :+#tombstone: [#009.D] 'Actual_Parameters_Ivar_Instance_Methods' un-abstacted
