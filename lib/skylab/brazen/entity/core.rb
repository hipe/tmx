module Skylab::Brazen

  module Entity

    class << self

      def [] * a
        via_argument_list a
      end

      def box
        Box_
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
        @kernel = @reader.init_property_scope_krnl
        r = if current_iambic_token.respond_to? :id2name
          when_remaining_args_look_iambic_execute
        else
          when_remaining_args_do_not_look_iambic_execute
        end
        @kernel.end_scope
        @reader.property_scope_krnl = nil
        r
      end

      def when_remaining_args_look_iambic_execute
        d = @kernel.process_any_DSL @d, @x_a
        d == @d and raise ::ArgumentError, say_strange_iambic
        @d = d
        @d < @x_a_length and when_remaining_args_do_not_look_iambic_execute
      end

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
        mod.extend Extension_Module_Methods__, Proprietor_Methods__
        mod.send :include, Iambic_Methods__
        mod.const_set READ_BOX__, Box_.new
        krn = mod.init_property_scope_krnl
        krn.apply_p @p
        krn.end_scope
        mod.property_scope_krnl = nil
        mod
      end

      def when_one_length_arg_list_item_is_client_execute
        @reader = @x_a.first
        to_reader_apply_setup
      end

      def to_reader_apply_setup
        @reader.extend Proprietor_Methods__
        @reader.send :include, Iambic_Methods__
        @reader.const_defined? READ_BOX__ or
          @reader.const_set READ_BOX__, Box_.new
        nil
      end
    end

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    class Scope_Kernel__  # formerly "flusher"

      def initialize reader, writer
        @reader = reader ; @writer = writer
        @has_writer_method_name_constraints = false
        @lstnrs = @prop = nil
        @x_a_a = []
      end

      def has_nonzero_length_iambic_queue
        @x_a_a.length.nonzero?
      end

      def add_iambic_row x_a
        @x_a_a.push x_a ; nil
      end

      def apply_p p
        Method_Added_Muxer__[ @reader ].for_each_method_added_in p, -> m_i do
          flush_because_method m_i
        end
        @x_a_a.length.nonzero? and flush_iambic_queue
        nil
      end

      def iambic_writer_method_name_suffix= i
        @has_writer_method_name_constraints = true
        @method_name_constraints_rx = /\A.+(?=#{ ::Regexp.escape i }\z)/
        @writer_method_name_suffix = i
      end

      def flush_because_method m_i
        plan_in_progress.meth_i = m_i
        if @x_a_a.length.nonzero?
          flush_iambic_queue
          @plan and flush_bc_meth
        else
          flush_bc_meth
        end ; nil
      end

      def plan_in_progress
        @plan ||= Property_Plan__.new
      end
      attr_reader :plan

      class Property_Plan__
        attr_accessor :meth_i, :prop_i
        def names
          [ @prop_i, @meth_i ]
        end
      end

      def flush_bc_meth
        if @has_writer_method_name_constraints
          @plan.prop_i = aply_method_name_constraints @plan.meth_i
        else
          @plan.prop_i = @plan.meth_i
        end
        did_build = touch_and_accept_prop
        did_build and finish_property
      end

      def flush_because_prop_i prop_i
        plan_in_progress.prop_i = prop_i
        @plan.meth_i = :"__PROCESS_IAMBIC_PARAMETER__#{ prop_i }"
        did_build = touch_and_accept_prop
        mxr = @reader.method_added_mxr and mxr.stop_listening
        @reader.send :define_method, @prop.iambic_writer_method_name,
          @prop.some_iambic_writer_method_proc
        mxr and mxr.resume_listening
        did_build and finish_property
      end

      def touch_and_accept_prop
        if @prop
          mutate_prop_in_progress
        else
          create_new_prop
          did_build = true
        end
        @plan = nil
        accept_property @prop
        did_build
      end

      def mutate_prop_in_progress
        @prop.set_prop_i_and_iambic_writer_method_name( * @plan.names )
        (( p = any_prop_hook @prop.class )) and p[ @prop ]
        nil
      end

      def create_new_prop
        p = any_prop_hook @reader::PROPERTY_CLASS__
        @prop = @reader::PROPERTY_CLASS__.new( * @plan.names, & p )
        nil
      end

      def any_prop_hook cls
        if cls.hook_shell and (( box = cls.hook_shell.props ))
          -> prop do
            box.each_pair do |i, p|
              if prop.send i
                p[ prop ]
              end
            end ; nil
          end
        end
      end

      def accept_property _PROPERTY_
        i = _PROPERTY_.name_i
        m_i = :"produce_#{ i }_property"
        @reader.prop_mthd_names_for_write.add_or_assert i, m_i
        @writer.send :define_method, m_i do _PROPERTY_ end
        nil
      end

      def finish_property
        if @prop.class.hook_shell
          @prop.class.hook_shell.process_relevant_later_hooks @reader, @prop
        end
        @prop = nil
      end

      def process_any_DSL d, x_a
        @scan = Iambic_Scanner.new d, x_a
        prcss_scan_as_DSL_passively
        d = @scan.current_index ; @scan = nil ; d
      end
    # ~
      attr_reader :meth_i, :reader, :scan
      attr_writer :prop

      def flush_iambic_queue
        @scan = Entity::Compound_Iambic_Scanner__.new @x_a_a
        prcss_scan_as_DSL_fully
        @x_a_a.clear ; @scan = nil
      end

      def prcss_scan_as_DSL_fully
        dsl = DSL__.new self, @scan
        begin
          dsl.execute
          @scan.unparsed_exists or break
          metaproperty_scanner.scan_some_DSL
          @scan.unparsed_exists or break
        end while true
      end

      def prcss_scan_as_DSL_passively
        dsl = DSL__.new self, @scan
        begin
          dsl.execute
          @scan.unparsed_exists or break
          @scan.current_token.respond_to? :id2name or break
          metaproperty_scanner.scan_some_DSL
          @scan.unparsed_exists or break
        end while true
      end

      def metaproperty_scanner
        @mprop_scnr ||= Entity::Meta_Property__::Mprop_Scanner.new self
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

      def end_scope
        if @lstnrs and (( box = @lstnrs[ :at_end_of_scope ] ))
          box.each_value( & :call )
        end
      end

      def listener_box_for_eventpoint i
        (( @lstnrs ||= {} )).fetch i do
          @lstnrs[ i ] = Box_.new
        end
      end
    end

    module Proprietor_Methods__

      def properties
        @properties ||= Entity::Properties__.new self
      end

      def property_method_nms_for_rd
        const_get READ_BOX__
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

      def o * x_a, & p
        if p
          krnl = init_property_scope_krnl
          x_a.length.nonzero? and krnl.add_iambic_row x_a
          krnl.has_nonzero_length_iambic_queue and krnl.flush_iambic_queue
          krnl.apply_p p
          krnl.end_scope
          @property_scope_krnl = nil
        else
          @property_scope_krnl.add_iambic_row x_a
        end ; nil
      end

      def property_class_for_write
        metaproperty_kernel.property_class_for_write_impl
      end

      def metaproperty_kernel
        @mprop_kernel ||= Entity::Meta_Property__::Client_Kernel.new self
      end

      attr_reader :method_added_mxr

      def add_iambic_event_listener i, p
        iambic_evnt_muxer_for_write.add i, p ; nil
      end
    private
      def iambic_evnt_muxer_for_write
        Entity::Meta_Property__::Muxer.for self
      end
    public
      def init_property_scope_krnl
        property_scope_krnl and self._SANITY
        @property_scope_krnl = build_property_scope_krnl
      end
      attr_accessor :property_scope_krnl
    private
      def build_property_scope_krnl
        Scope_Kernel__.new self, singleton_class
      end
    end

    class Box_

      def initialize
        @a = [] ; @h = {}
      end

      def freeze
        @a.freeze ; @h.freeze ; super
      end

      def initialize_copy _otr_
        @a = @a.dup ; @h = @h.dup ; nil
      end

      def length
        @a.length
      end

      def has_name i
        @h.key? i
      end

      def first_name
        @a.first
      end

      def get_names
        @a.dup
      end

      def [] i
        @h[ i ]
      end

      def fetch i, & p
        @h.fetch i, & p
      end

      def at_position d
        @h.fetch @a.fetch d
      end

      def to_key_scanner
        d = -1 ; last = @a.length - 1
        Callback_::Scn.new do
          if d < last
            @a.fetch d += 1
          end
        end
      end

      def to_value_scanner
        d = -1 ; last = @a.length - 1
        Callback_::Scn.new do
          if d < last
            @h.fetch @a.fetch d += 1
          end
        end
      end

      def each_value
        @a.each do |i| yield @h.fetch( i ) end ; nil
      end

      def each_pair
        @a.each do |i| yield i, @h.fetch( i ) end ; nil
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

      def add_if_not_has i, & p
        @h.fetch i do
          @a.push i
          @h[ i ] = p.call
        end ; nil
      end

      def add_or_replace i, x
        @h.fetch i do
          @a.push i
        end
        @h[ i ] = x ; nil
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

      def self.the_empty_box
        @teb ||= new.freeze
      end
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
        @iambic_writer_method_proc = nil
        a.length.nonzero? and set_prop_i_and_iambic_writer_method_name( * a )
        notificate :at_end_of_process_iambic
        block_given? and yield self
        freeze
      end

      attr_reader :iambic_writer_method_name, :name

      attr_accessor :iambic_writer_method_proc

      def set_prop_i_and_iambic_writer_method_name prop_i, meth_i
        @name = Callback_::Name.from_variegated_symbol prop_i
        @iambic_writer_method_name = meth_i ; nil
      end

      def some_iambic_writer_method_proc
        if @iambic_writer_method_proc
          @iambic_writer_method_proc
        else
          bld_monadic_iambic_writer_method_proc
        end
      end

      def bld_monadic_iambic_writer_method_proc
        _IVAR_ = @name.as_ivar
        -> do
          instance_variable_set _IVAR_, iambic_property ; nil
        end
      end

      def as_ivar
        @name.as_ivar
      end

      def name_i
        @name.as_variegated_symbol
      end

      class << self
        def hook_shell_for_write
          @hook_shell ||= Meta_Property__::Hook_Shell.new self
        end

        attr_reader :hook_shell
      end
    end

    if ! ::Object.private_method_defined? :notificate
      class ::Object
      private
        def notificate i  # :+[#sl-131] the easiest implementation for this
        end
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
        subject = property_proprietor
        box = subject ? subject.property_method_nms_for_rd : MONADIC_EMPTINESS_
        while @d < @x_a_length
          m_i = box[ @x_a[ @d ] ]
          m_i or break
          @d += 1
          send subject.send( m_i ).iambic_writer_method_name
        end
        self
      end

      def property_proprietor
        self.class
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

      PROPERTY_CLASS__ = Property__  # delicate
    end

    MONADIC_EMPTINESS_ = -> _ { }

    UNDEFINED_ = nil

    module Iambic_Methods_via_Scanner__
      include Iambic_Methods__

      def scan= x
        @scan = x
      end

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

      def advance_iambic_scanner_by_one
        @scan.advance_one
      end
    end

    # ~ bootstrapping

    class Common_Shell__
      include Iambic_Methods__
    end

    class Property__
      Entity[ self ]  # ~ property as entity
      include Iambic_Methods_via_Scanner__
      public :process_iambic_passively
    end

    # ~ core DSL

    class DSL__

      def initialize kernel, scan
        @kernel = kernel ; @scan = scan
      end

      def execute
        process_iambic_passively ; nil
      end

      Entity[ self, -> do

        def iambic_writer_method_name_suffix
          @kernel.iambic_writer_method_name_suffix = iambic_property
        end

        def meta_property
          _pc = @kernel.reader.metaproperty_kernel.property_cls_for_wrt
          Entity::Meta_Property__.new( @scan ).apply_to_property_class _pc
        end

        def properties
          begin
            @kernel.flush_because_prop_i @scan.gets_one
          end while @scan.unparsed_exists
        end

        def property
          @kernel.flush_because_prop_i iambic_property
        end
      end ]

      include Iambic_Methods_via_Scanner__
    end

    class Iambic_Scanner

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
    private
      def build_property_scope_krnl
        Scope_Kernel__.new self, const_get( :Module_Methods, false )
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
          @reader.const_set READ_BOX__, Box_.new
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
