module Skylab::Brazen

  module Entity  # [#001]

    class << self

      def [] * a
        via_arglist a
      end

      def call * a, & p
        via_arglist a, & p
      end

      def event
        Brazen_::Event__
      end

      def via_stream_iambic_methods
        Via_Scanner_Iambic_Methods_
      end

      def iambic_stream
        Callback_.iambic_stream
      end

      def method_added_muxer
        Method_Added_Muxer__
      end

      def mutable_iambic_stream
        Entity::Compound_Iambic_Scanner__::Mutable_Iambic_Scanner
      end

      def properties_stack
        self::Properties_Stack__
      end

      def proprietor_methods
        Proprietor_Methods__
      end

      def scope_kernel
        Scope_Kernel__
      end

      def via_arglist x_a, & edit_p
        d = x_a.length
        if d.zero?
          Produce_extension_module__.new( & edit_p ).execute
        else
          cls = x_a.fetch 0
          cls.extend Module_Methods__
          cls.entity_edit_sess do |sess|
            sess.process_iambic_flly x_a[ 1 .. -1 ], & edit_p
          end
        end
      end
    end

    # ~ writing properties (without metaproperties)

    module Extension_Module_Methods__

      def method_added m_i
        if @active_entity_edit_session
          @active_entity_edit_session.receive_method_added_name m_i
        end
        super
      end

      attr_accessor :active_entity_edit_session

      def call cls, & p
        self[ cls ]
        cls.entity_edit_sess do
          cls.module_exec( & p )
        end
      end

      def [] cls
        if cls.const_defined? :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___
          did_already = true
        else
          cls.extend Module_Methods__
        end
        cls.extend self::Module_Methods
        cls.include self
        if did_already
          _my_box = self::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___
          _their_box = cls.entity_formal_property_method_names_box_for_wrt
          _their_box.ensuring_same_values_merge_box! _my_box
        else
          cls.entity_formal_property_method_names_box_for_wrt  # copy them now
        end
        cls
      end
    end

    METHODIC_ = Callback_::Actor.methodic_lib

    module Edit_Session_Methods__

      include METHODIC_.iambic_processing_instance_methods

      def init_module mod
        mod.include Instance_Methods__
        @iambic_writer_method_writee_module = mod
        @pay_attention_to_method_added = true
        @property_class = Property__
        nil
      end

      def process_iambic_stream_fully stream  # [cb] #override
        process_iambic_stream_passively stream
        if stream.unparsed_exists
          self._DO_ME
        end
        if true
          ACHIEVED_
        else
          when_after_process_iambic_fully_stream_has_content stream
        end
      end

      def receive_method_added_name m_i
        if @pay_attention_to_method_added
          @do_define_method = false
          @iambic_writer_method_name = m_i
          _via_plan_realize_property_via_variegated_symbol m_i
        end
        nil
      end

    private

      def properties=
        stream = @__methodic_actor_iambic_stream__
        ok = true
        while stream.unparsed_exists
          ok = send :property=
          ok or break
        end
        ok
      end

      def property=
        name_i = iambic_property
        @do_define_method = true
        @iambic_writer_method_name = :"___entity_#{ name_i }_iambic_writer___"
        _via_plan_realize_property_via_variegated_symbol name_i
      end

      def _via_plan_realize_property_via_variegated_symbol name_i
        iwmn = flsh_some_iambic_writer_method_name

        prop = @property_class.new do
          @name = Callback_::Name.via_variegated_symbol name_i
          @iwmn = iwmn
        end

        acpt_property prop
      end

      def flsh_some_iambic_writer_method_name
        @iambic_writer_method_name or self._SANITY
        x = @iambic_writer_method_name
        @iambic_writer_method_name = nil
        x
      end

      def reuse=
        @do_define_method = true
        _prop_a = iambic_property
        ok = true
        _prop_a.each do | prop |
          ok = acpt_property prop
          ok or break
        end
        ok
      end

      def acpt_property prop
        if @do_define_method
          befor = @pay_attention_to_method_added
          @pay_attention_to_method_added = false
          @iambic_writer_method_writee_module.send(
            :define_method,
            prop.iambic_writer_method_name,
            prop.iambic_writer_method_proc )
          @pay_attention_to_method_added = befor
        end

        box = @writable_formal_propery_method_names_box
        name_i = prop.name_i
        do_add = false
        meth_i = box.fetch name_i do
          do_add = true
          :"___#{ name_i }_property___"
        end
        if do_add
          box.add name_i, meth_i
        end

        _PROPERTY = prop
        @formal_property_writee_module.send :define_method, meth_i do
          _PROPERTY
        end

        ACHIEVED_
      end
    end

    class Produce_extension_module__

      include Edit_Session_Methods__

      def initialize & p
        @p = p
      end

      def execute

        mod = ::Module.new
        box = Callback_::Box.new
        mod_ = ::Module.new

        mod.const_set :Module_Methods, mod_  # :+#public-API (the name)
        mod.const_set :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___, box

        mod.include METHODIC_.iambic_processing_instance_methods
        init_module mod
        mod.extend Extension_Module_Methods__

        @formal_property_writee_module = mod_
        @writable_formal_propery_method_names_box = box

        mod.active_entity_edit_session = self
        mod.module_exec( & @p )
        mod.active_entity_edit_session = nil
        mod
      end

    end

    class Class_Edit_Session__

      include Edit_Session_Methods__

      def initialize cls
        Callback_::Actor.methodic cls
        init_module cls
        @formal_property_writee_module = cls.singleton_class
        @writable_formal_propery_method_names_box =
          cls.entity_formal_property_method_names_box_for_wrt
      end

      def process_iambic_flly x_a, & edit_p
        ok = true
        if x_a.length.nonzero?
          ok = process_iambic_fully x_a
        end
        ok and begin
          if edit_p
            @iambic_writer_method_writee_module.module_exec( & edit_p )  # so result is user's result
          else
            @iambic_writer_method_writee_module  # so `[]` is wrappable
          end
        end
      end

      def finish
        nil
      end
    end

    # ~ the enhancement modules & classes

    module Module_Methods__

      def properties
        entity_formal_property_method_names_box_for_rd.to_value_scan.map_by do |i|
          send i
        end.immutable_with_random_access_keyed_to_method :name_i
      end

      def entity_edit_sess
        sess = Class_Edit_Session__.new self
        @active_entity_edit_session = sess
        x = yield sess
        sess.finish
        @active_entity_edit_session = nil
        x
      end

      def method_added m_i
        if active_entity_edit_session
          @active_entity_edit_session.receive_method_added_name m_i
        end
        super
      end

      attr_reader :active_entity_edit_session

      def entity_formal_property_method_names_box_for_wrt
        @entity_formal_property_method_names_box_for_write ||= begin
          const_set :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___,
            self::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___.dup
        end
      end

      def entity_formal_property_method_names_box_for_rd
        self::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___
      end

    private

      def o * x_a, & edit_p
        if active_entity_edit_session
          sess = @active_entity_edit_session
        else
          self._DO_ME
        end
        sess.process_iambic_flly x_a, & edit_p
      end
    end

    module Instance_Methods__

      ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___ = Callback_::Box.the_empty_box

      def initialize & p   # #experimental
        instance_exec( & p )
      end

    private

      def iambic_writer_method_name_passive_lookup_proc  # [cb] #hook-in
        bx = self.class.entity_formal_property_method_names_box_for_rd
        -> name_i do
          m_i = bx[ name_i ]
          if m_i
            self.class.send( m_i ).iambic_writer_method_name
          end
        end
      end

      def receive_entity_property_value prop, x
        instance_variable_set prop.as_ivar, x
        ACHIEVED_
      end
    end

    class Property__ < METHODIC_.simple_property_class

      def iambic_writer_method_name
        @iwmn
      end

    private

      def iambic_writer_method_proc_when_arity_is_one
        _NAME_I = name_i
        -> do
          _prop = self.class.send self.class.entity_formal_property_method_names_box_for_wrt.fetch _NAME_I
          receive_entity_property_value _prop, iambic_property  # RESULT VALUE
        end
      end

      def iambic_writer_method_proc_when_arity_is_zero
        _NAME_I = name_i
        -> do
          _prop = self.class.send self.class.entity_formal_property_method_names_box_for_wrt.fetch _NAME_I
          receive_entity_property_value _prop, true  # RESULT VALUE
        end
      end
    end

    if false

      # WAS: read [#001] the entity enhancement narrrative

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    class Scope_Kernel__  # formerly "flusher"

      def initialize reader, writer
        @ad_hocs_are_known = false
        @reader = reader ; @writer = writer
        @has_writer_method_name_constraints = false
        @lstnrs = @plan = @previous_plan = @prop = nil
        @x_a_a = []
      end

      # ~

      def accept_ad_hoc_processor
        Entity::Ad_Hoc_Processor__.new @scanner, @reader, @writer
      end

      def scan_anything_with_any_ad_hoc_processors
        @ad_hocs_are_known or determine_if_ad_hocs_exist
        @ad_hocs_exist and @ad_hoc_scan.scan_any
      end

      def determine_if_ad_hocs_exist
        @ad_hocs_are_known = true
        if @reader.const_defined? :AD_HOC_PROCESSORS__
          @ad_hoc_scan = @reader::AD_HOC_PROCESSORS__.
            build_scan @scanner, @reader, @writer
          @ad_hocs_exist = true
        else
          @ad_hocs_exist = false
        end ; nil
      end

      def iambic_writer_method_name_suffix= i
        @has_writer_method_name_constraints = true
        @method_name_constraints_rx = /\A.+(?=#{ ::Regexp.escape i }\z)/
        @writer_method_name_suffix = i
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

      def finish_property
        if @prop.class.hook_shell
          @prop.class.hook_shell.process_relevant_later_hooks @reader, @prop
        end
        @prop = nil
        ACHIEVED_
      end

      def process_any_DSL d, x_a
        @scanner = Lib_::Mutable_iambic_scanner[].new d, x_a
        prcss_scan_as_DSL_passively
        d = @scanner.current_index ; @scanner = nil ; d
      end

      # ~

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

      # ~ look like actor - assembly required (experiment)

      def with * x_a, & p
        via_iambic x_a, p
      end

      def via_iambic x_a, p=nil
        ent = build_via_iambic x_a, p
        ent && ent.execute
      end

      def build_with * x_a, & p
        build_via_iambic x_a, p
      end

      def build_via_iambic x_a, p=nil
        did = false ; ok = nil
        ent = new do
          did = true
          ok = process_iambic_fully x_a
        end
        did && ok && ent
      end

      # ~

      def properties
        @properties ||= build_props
      end

      def clear_properties
        @properties = nil
      end

      def property_method_nms_for_rd
        const_get READ_BOX__
      end

      def property_method_nms_for_wrt
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

      def set_property_class x
        metaproperty_kernel.set_property_class x
      end

      def property_class_for_write
        metaproperty_kernel.property_class_for_write_impl
      end

      def metaproperty_kernel
        @mprop_kernel ||= Entity::Meta_Property__::Client_Kernel.new self
      end

      def ignore_added_methods
        mxr = method_added_mxr
        if mxr
          mxr.stop_listening
        end
        x = yield
        if mxr
          mxr.resume_listening
        end
        x
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

    class Method_Added_Muxer__  # from [mh] re-written
      class << self
        def via_arglist a
          self[ * a ]
        end
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
        notificate :at_end_of_process_iambic
        block_given? and yield self
        freeze
      end

      def set_prop_i_and_iambic_writer_method_name prop_i, meth_i=nil
        @name = Callback_::Name.via_variegated_symbol prop_i
        @iambic_writer_method_name = meth_i ; nil
      end

      def description
        @name.as_variegated_symbol
      end

      def as_ivar
        @name.as_ivar
      end

      def name_i
        @name.as_variegated_symbol
      end

    private

      def build_not_OK_event_with * x_a, & p
        Brazen_.event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
      end

      def maybe_send_event *, & ev_p
        raise ev_p[].to_exception
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

    module Xxx

      # ~ experimental property reflection API

      def bound_properties
        @bp ||= Entity::Properties_Stack__::Bound_properties[
          method( :get_bound_property_via_property ), self.class.properties ]
      end

      def get_bound_property_via_property prop
        had = true
        x = actual_property_box.fetch prop.name_i do
          had = false ; nil
        end
        Brazen_::Lib_::Trio[].new x, had, prop
      end

      PROPERTY_CLASS__ = Property__  # delicate
    end

    module Xxx_

      def when_no_iambic_property
        maybe_send_event :error, :missing_required_properties do
          bld_MRP_event
        end
      end

      def bld_MRP_event
        build_not_OK_event_with :missing_required_properties,
            :previous_token, @scanner.previous_token,
            :error_category, :argument_error do |y, o|

          y << "expecting a value for #{ code o.previous_token }"
        end
      end

      def current_iambic_token
        @scanner.current_token
      end

      def advance_iambic_stream_by_one
        @scanner.advance_one
      end
    end

    # ~ bootstrapping

    class Common_Shell__
      include Iambic_Methods__
    end

    class Property__
      Entity[ self ]  # ~ property as entity
      include Via_Scanner_Iambic_Methods_
      public :process_iambic_passively
    end

    # ~ core DSL

    class DSL__

      def initialize kernel, scanner
        @kernel = kernel ; @scanner = scanner
      end

      def execute
        process_iambic_passively ; nil
      end

      Entity[ self, -> do

        def ad_hoc_processor
          @kernel.accept_ad_hoc_processor
        end

        def iambic_writer_method_name_suffix
          @kernel.iambic_writer_method_name_suffix = iambic_property
        end

        def meta_property
          _pc = @kernel.reader.metaproperty_kernel.property_cls_for_wrt
          Entity::Meta_Property__.new( @scanner ).apply_to_property_class _pc
        end

      end ]

      include Via_Scanner_Iambic_Methods_

    private

      def build_not_OK_event_with * x_a, & p
        Brazen_.event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, p
      end

      def maybe_send_event *, & ev_p
        raise ev_p[].to_exception
      end
    end
    end

    Entity_ = self
  end
end
