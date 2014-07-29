module Skylab::Brazen

  module Entity

    class << self

      def [] * a
        via_argument_list a
      end

      def via_argument_list a
        Shell__.new.execute_via_argument_list a
      end
    end

    class Common_Shell__  # read [#001] the entity enhancement narrrative

      def execute_via_argument_list x_a
        @d = 0 ; @x_a = x_a ; @x_a_length = x_a.length
        case @x_a_length <=> 1
        when  1 ; when_many_length_arg_list_execute
        when  0 ; when_one_length_arg_list_execute
        end
      end

    private

      def when_one_length_arg_list_execute  # build extension moudule via proc
        if current_iambic_token.respond_to? :arity
          when_one_length_arg_list_item_is_proc_execute
        else
          when_one_length_arg_list_item_is_client_execute
        end
      end

      def when_many_length_arg_list_execute  # more than one
        @reader = iambic_property  # see [#001]:#reader-vs-writer
        to_reader_apply_setup
        _writer = @reader.singleton_class
        @kernel = Kernel__.new @reader, _writer
        if current_iambic_token.respond_to? :id2name
          when_remaining_args_look_iambic_execute
        else
          when_remaining_args_do_not_look_iambic_execute
        end
      end

    private

      def when_remaining_args_do_not_look_iambic_execute
        d = @x_a_length - @d
        1 == d or raise ::ArgumentError, "(#{ d } for 1 remaining arg)"
        p = current_iambic_token
        p.respond_to? :arity or raise ::ArgumentError, say_expecting_proc
        clear_all_iambic_ivars
        @kernel.apply_p p ; nil
      end
    end

    class Shell__ < Common_Shell__
    private

      def when_one_length_arg_list_item_is_proc_execute
        @p = @x_a.first
        mod = ::Module.new
        mod.const_set :Module_Methods, ::Module.new
        mod.extend Proprietor_Methods__
        mod.extend Extension_Module_Methods__
        mod.send :include, Iambic_Methods__
        mod.const_set READ_BOX__, Box__.new
        @reader = mod
        aply_p_to_reader_which_is_new_extension_module
        mod
      end

      def when_one_length_arg_list_item_is_client_execute
        @reader = @x_a.first
        to_reader_apply_setup
      end

      def when_remaining_args_look_iambic_execute
        dsl = DSL__.new @kernel, @d, @x_a
        d = @d
        dsl.execute
        @d = dsl.current_iambic_index
        d == @d and raise ::ArgumentError, say_strange_iambic
        @d < @x_a_length and when_remaining_args_do_not_look_iambic_execute
      end

      def to_reader_apply_setup
        @reader.extend Proprietor_Methods__
        @reader.send :include, Iambic_Methods__
        @reader.const_defined? READ_BOX__ or
          @reader.const_set READ_BOX__, Box__.new
        nil
      end

      def aply_p_to_reader_which_is_new_extension_module
        _writer = @reader::Module_Methods
        @kernel = Kernel__.new @reader, _writer
        @kernel.apply_p @p ; nil
      end
    end

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    class Kernel__  # formerly "flusher"

      def initialize reader, writer
        @reader = reader ; @writer = writer
        @has_writer_method_name_constraints = false
        @prop = nil
      end

      def apply_p p
        Method_Added_Muxer__[ @reader ].for_each_method_added_in p, -> m_i do
          flush_because_method m_i
        end
        @reader.has_nonzero_length_iambic_queue and flsh_trailing_DSL
        nil
      end
    private
      def flsh_trailing_DSL
        flsh_iambic_queue
      end
    public

      def iambic_writer_method_name_suffix= i
        @has_writer_method_name_constraints = true
        @method_name_constraints_rx = /\A.+(?=#{ ::Regexp.escape i }\z)/
        @writer_method_name_suffix = i
      end

      def flush_because_method m_i
        @meth_i = m_i
        if @reader.has_nonzero_length_iambic_queue
          flsh_iambic_queue
          @meth_i and flush_bc_meth
        else
          flush_bc_meth
        end ; nil
      end
    private
      def flush_bc_meth
        m_i = @meth_i ; @meth_i = nil
        prop_i = @has_writer_method_name_constraints ?
          aply_method_name_constraints( m_i ) : m_i
        if @prop
          @prop.set_prop_i_and_iambic_writer_method_name prop_i, m_i
        else
          did_build = true
          @prop = @reader::PROPERTY_CLASS__.new prop_i, m_i
        end
        prop_accept
        did_build and @prop = nil
      end
    public

      def flush_because_prop_i prop_i
        @meth_i = nil
        m_i = :"__PROCESS_IAMBIC_PARAMETER__#{ prop_i }"
        if @prop
          @prop.set_prop_i_and_iambic_writer_method_name prop_i, m_i
        else
          did_build = true
          @prop = @reader::PROPERTY_CLASS__.new prop_i, m_i
        end
        prop_accept
        mxr = @reader.method_added_mxr and mxr.stop_listening
        _IVAR_ = @prop.as_ivar
        @reader.send :define_method, @prop.iambic_writer_method_name do
          instance_variable_set _IVAR_, iambic_property ; nil
        end
        mxr and mxr.resume_listening
        did_build and @prop = nil
      end

      def flush_iambic_queue
        flsh_iambic_queue
      end

    private

      def flsh_iambic_queue
        x_a_a = @reader.iambic_queue
        @scan = Entity::Compound_Iambic_Scanner__.new x_a_a
        dsl = DSL__.new self, @scan
        begin
          dsl.execute
          @scan.unparsed_exists or break
          twds_prop_scan_some_DSL_as_metaproperties_being_used
          @scan.unparsed_exists or break
        end while true
        @scan = nil
        x_a_a.clear ; nil
      end

      def aply_method_name_constraints m_i
        md = @method_name_constraints_rx.match m_i.to_s
        md or raise ::NameError, say_did_not_have_expected_suffix( m_i )
        md[ 0 ].intern
      end
      def say_did_not_have_expected_suffix m_i
        "did not have expected suffix '#{ @writer_method_name_suffix }'#{
          }: '#{ m_i }'"
      end

      def prop_accept
        i = @prop.name_i
        m_i = :"produce_#{ i }_property"
        @reader.prop_mthd_names_for_write.add_or_assert i, m_i
        _PROPERTY_ = @prop
        @writer.send :define_method, m_i do _PROPERTY_ end
        @prop.might_have_entity_class_hooks and prcs_any_ent_cls_hks
        nil
      end
    end

    module Proprietor_Methods__

      def properties
        @properties ||= Entity::Properties__.new( self )
      end

      def prop_mthd_names_for_write
        if const_defined? WRITE_BOX__, false
          const_get WRITE_BOX__, false
        elsif const_defined? READ_BOX__, false
          const_set WRITE_BOX__, const_get( READ_BOX__, false )
        else
          props = property_method_nms_for_rd.dup
          const_set WRITE_BOX__, props
          const_set READ_BOX__, props
          props
        end
      end

      def property_method_nms_for_rd
        const_get READ_BOX__
      end

      def o * x_a, & p
        x_a.length.zero? or some_iambic_queue.push x_a
        p and flsh_with_property_definition_block p ; nil
      end

      def some_iambic_queue
        @iambic_queue ||= []
      end

      def has_nonzero_length_iambic_queue
        iambic_queue and @iambic_queue.length.nonzero?
      end

      attr_reader :iambic_queue, :method_added_mxr
    end

    class Box__

      def initialize
        @a = [] ; @h = {}
      end

      def initialize_copy _otr_
        @a = @a.dup ; @h = @h.dup ; nil
      end

      def length
        @a.length
      end

      def get_local_normal_names
        @a.dup
      end

      def [] i
        @h[ i ]
      end

      # ~ mutators

      def ensuring_same_values_merge_box! otr
        a = otr.a ; h = otr.h
        a.each do |i|
          had = true
          m_i = @h.fetch i do
            had = false
          end
          if had
            m_i == @h.fetch( i ) or raise "merge failure near #{ m_i }"
          else
            @a.push i ; @h[ i ] = h.fetch i
          end
        end ; nil
      end

      def add_or_assert i, x
        has = true
        x_ = @h.fetch i do
          has = false
        end
        if has
          x == x_ or raise "assertion failure - not equal: (#{ x }, #{ x_ })"
          nil
        else
          @a.push i ; @h[ i ] = x ; true
        end
      end

      def add i, x
        had = true
        @h.fetch i do had = nil ; @a.push i ; @h[ i ] = x end
        had and raise ::KeyError, "won't clobber existing '#{ i }'"
      end

    protected
      attr_reader :a, :h
    end

    class Method_Added_Muxer__  # from [mh] re-written
      class << self
        def [] mod
          me = self
          mod.module_exec do
            @method_added_mxr ||= me.bld_for self
          end
        end
        def bld_for client
          muxer = new client
          client.send :define_singleton_method, :method_added do |m_i|
            muxer.method_added_notify m_i
          end
          muxer
        end
      end
      def initialize reader
        @reader = reader ; @p = nil
      end
      def for_each_method_added_in defs_p, do_p
        add_listener do_p
        @reader.module_exec( & defs_p )
        remove_listener do_p
      end
      def add_listener p
        @p and fail "not implemented - actual muxing"
        @p = p ; nil
      end
      def remove_listener _
        @p = nil
      end
      def stop_listening
        @stopped_p = @p ; @p = nil
      end
      def resume_listening
        @p = @stopped_p ; @stopped_p = nil
      end
      def method_added_notify method_i
        @p && @p[ method_i ] ; nil
      end
    end

    class Property__

      def initialize *a
        a.length.nonzero? and set_prop_i_and_iambic_writer_method_name( * a )
        block_given? and yield self
        emit_iambic_event :at_end_of_process_iambic
        freeze
      end

      attr_reader :iambic_writer_method_name, :name

      def set_prop_i_and_iambic_writer_method_name prop_i, meth_i
        @name = Callback_::Name.from_variegated_symbol prop_i
        @iambic_writer_method_name = meth_i ; nil
      end

      def as_ivar
        @name.as_ivar
      end

      def name_i
        @name.as_variegated_symbol
      end

      def might_have_entity_class_hooks  # :+#re-defined elsewhere
        false
      end
    end

    # ~ iambics

    module Iambic_Methods__
    private

      def with * a
        process_iambic_fully 0, a
        clear_all_iambic_ivars
        self
      end

      def process_iambic_fully * a
        prcss_iambic_passively_via_args a
        unparsed_iambic_exists and raise ::ArgumentError, say_strange_iambic
        self
      end

      def unparsed_iambic_exists
        @d < @x_a_length
      end

      def say_strange_iambic
        "unrecognized property '#{ current_iambic_token }'"
      end

      def process_iambic_passively * a
        prcss_iambic_passively_via_args a
      end

      def prcss_iambic_passively_via_args a
        prep_iambic_parse_via_args a
        prcss_iambic_passively
      end

      def prep_iambic_parse_via_args a
        case a.length
        when 1 ; @d ||= 0 ; @x_a, = a ; @x_a_length = @x_a.length
        when 2 ; @d, @x_a = a ; @x_a_length = @x_a.length
        end ; nil
      end

      def prcss_iambic_passively
        subject = self.class
        box = subject.property_method_nms_for_rd
        while @d < @x_a_length
          m_i = box[ @x_a[ @d ] ]
          m_i or break
          @d += 1
          send subject.send( m_i ).iambic_writer_method_name
        end
        self
      end

      def iambic_property
        x = @x_a.fetch @d
        @d += 1
        x
      end

      def current_iambic_token
        @x_a.fetch @d
      end

      def clear_all_iambic_ivars
        @d = @x_a = @x_a_length = nil
        UNDEFINED_
      end

      def emit_iambic_event _  # :#re-defined elsewhere
      end

      PROPERTY_CLASS__ = Property__  # delicate
    end

    UNDEFINED_ = nil

    # ~ bootstrapping & core DSL

    class Common_Shell__
      include Iambic_Methods__
    end

    class Property__
      include Iambic_Methods__
    end

    module Iambic_Methods_via_Scanner__
      include Iambic_Methods__

    private
      def prep_iambic_parse_via_args a
        a.length.zero? or raise ::ArgumentError, say_not_when_scan( a )
      end

      def prcss_iambic_passively
        reader = self.class
        box = reader.property_method_nms_for_rd
        while unparsed_iambic_exists
          m_i = box[ current_iambic_token ]
          m_i or break
          advance_iambic_scanner_by_one
          send reader.send( m_i ).iambic_writer_method_name
        end ; nil
      end

      def unparsed_iambic_exists
        @scan.unparsed_exists
      end

      def iambic_property
        @scan.unparsed_exists or raise ::ArgumentError, say_missing_iambic_value
        @scan.gets_one
      end
      def say_missing_iambic_value
        "expecting a value for '#{ @scan.previous_token }'"
      end

      def current_iambic_token
        @scan.current_token
      end

      def current_iambic_index
        @scan.current_index
      end

      def advance_iambic_scanner_by_one
        @scan.advance_one
      end
    end

    class DSL__

      include Iambic_Methods_via_Scanner__

      def initialize kernel, d, x_a=nil
        @kernel = kernel
        if x_a
          @scan = Iambic_Scanner_.new d, x_a
        else
          @scan = d
        end
      end

      def execute
        process_iambic_passively
        nil
      end

      public :current_iambic_index, :unparsed_iambic_exists

    private

      Entity[ self, -> do

        def iambic_writer_method_name_suffix
          @kernel.iambic_writer_method_name_suffix = iambic_property
        end

        def meta_property
          _mp = Entity::Meta_Property__.new @scan
          _mp.apply_to_property_class @kernel.property_class_for_write
        end

        def property
          @kernel.flush_because_prop_i iambic_property
        end
      end ]
    end

    class Iambic_Scanner_

      def initialize d, x_a
        @d = d ; @x_a = x_a ; @x_a_length = @x_a.length
      end

      def unparsed_exists
        @d != @x_a_length
      end

      def gets_one
        x = current_token ; advance_one ; x
      end

      def current_token
        @x_a.fetch @d
      end

      def previous_token
        @x_a.fetch @d - 1
      end

      def current_index
        @d
      end

      def advance_one
        @d += 1 ; nil
      end
    end

    # ~ extension API

    module Extension_Module_Methods__

      def [] *a
        Extension_Shell__.new.execute_via_extmod_and_arglist self, a
      end
    end

    class Extension_Shell__ < Common_Shell__

      def execute_via_extmod_and_arglist extension_module, arg_list
        @extension_module = extension_module
        execute_via_argument_list arg_list
      end

      def when_one_length_arg_list_execute
        @reader = @x_a.first
        to_reader_apply_setup ; nil
      end

      def to_reader_apply_setup
        @reader.extend Proprietor_Methods__
        @reader.extend @extension_module::Module_Methods
        if ! @reader.const_defined? READ_BOX__  # before we do any includes
          @reader.const_set READ_BOX__, Box__.new
        end
        @reader.send :include, @extension_module  # iambic methods too
        _box = @reader.prop_mthd_names_for_write
        _box_ = @extension_module.property_method_nms_for_rd
        _box.ensuring_same_values_merge_box! _box_ ; nil
      end
    end

    Entity = self
  end
end
