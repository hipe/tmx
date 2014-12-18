module Skylab::Brazen

  module Entity  # [#001]

    class << self

      def [] * a
        via_arglist a
      end

      def build_bad_enum_value_event_method_proc
        -> x, name_sym, enum_box do
          build_not_OK_event_with :invalid_property_value,
            :x, x, :name_symbol, name_sym,
            :enum_box, enum_box,
            :error_category, :argument_error do |y, o|
              _a = o.enum_box.get_names
              y << "invalid #{ o.name_symbol } #{ ick o.x }, #{
               }expecting { #{ _a * ' | ' } }"
          end
        end
      end

      def call * a, & p
        via_arglist a, & p
      end

      def event
        Brazen_::Event__
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
          o = Extension_Module_Production_Session__.new( & edit_p )
          o.init_to_create_new_module
          o.execute
        else
          st = Callback_::Iambic_Stream.via_array( x_a )
          cls = st.gets_one
          Callback_::Actor.methodic cls
          cls.extend Module_Methods__
          cls.edit_entity_class do |sess|
            sess.receive_edit st, & edit_p
          end
        end
      end
    end

    MODULE_ATTR_READER_WRITER_METHOD__ = -> rd_i=nil, wrt_i, _CONST, _IVAR, & bld_p do  # #note-065

      if rd_i
        define_method rd_i do
          const_get _CONST
        end
      end

      define_method wrt_i do
        if instance_variable_defined? _IVAR
          instance_variable_get _IVAR
        else
          x = bld_p[ self ]
          const_set _CONST, x
          instance_variable_set _IVAR, x
          x
        end
      end ; nil
    end

    # ~ parsing support

    METHODIC_ = Callback_::Actor.methodic_lib

    class Nonterminal_ < ::Proc
      alias_method :receive_parse_context, :call
    end

    class Methodic_as_Nonterminal_

      class << self
        alias_method :[], :new
      end

      def initialize up
        @p = up.method :process_iambic_stream_passively
      end

      def receive_parse_context pc
        @p[ pc.upstream ]
      end
    end

    class Adaptive_Nonterminal_Queue_  # read #note-185

      def initialize * passive_parsers, & oes_p
        @on_event_selectively = oes_p
        @a = passive_parsers
      end

      def receive_parse_context pc
        ok = true
        nonfront_matching_index = nil
        st = pc.upstream
        while st.unparsed_exists
          d = st.current_index
          input_was_consumed = false
          @a.each_with_index do |cx, idx|
            ok = cx.receive_parse_context pc
            ok or break
            if d != st.current_index
              idx.nonzero? and nonfront_matching_index = idx
              input_was_consumed = true
              break
            end
          end
          input_was_consumed or break
        end
        nonfront_matching_index and reorder nonfront_matching_index
        ok
      end

      private def reorder d
        a = ::Array.new @a.length
        a[ 0 ] = @a.fetch d
        a[ 1, d ] = @a[ 0, d ]
        if d < @a.length - 1
          same = d + 1 ... @a.length
          a[ same ] = @a[ same ]
        end
        @a = a
        nil
      end

      def replace_item x, x_
        oid = x.object_id
        _d = @a.index do |x__|
          oid == x__.object_id
        end
        @a[ _d ] = x_
        nil
      end
    end

    class Parse_Context__

      def initialize upstream, edit_session
        @edit_session = edit_session
        @upstream = upstream
      end

      attr_reader :edit_session, :upstream

      def downstream
        @edit_session.iambic_writer_method_writee_module
      end
    end

    # ~ parsing the DSL: edit sessions for modules and classes

    class Module_Edit_Session__

      include METHODIC_.iambic_processing_instance_methods

    end

    class Extension_Module_Production_Session__ < Module_Edit_Session__

      def initialize & edit_p
        @edit_p = edit_p
      end

      def init_to_create_new_module

        @iambic_writer_method_writee_module = ::Module.new
        @writable_formal_propery_method_names_box = Callback_::Box.new
        @formal_property_writee_module = ::Module.new

        @iambic_writer_method_writee_module.include METHODIC_.iambic_processing_instance_methods

        @iambic_writer_method_writee_module.include Instance_Methods

        nil
      end

      def init_to_produce_extension_of_extension extmod

        @iambic_writer_method_writee_module = ::Module.new
        @writable_formal_propery_method_names_box =
          extmod::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___.dup
        @formal_property_writee_module = ::Module.new

        @iambic_writer_method_writee_module.include extmod
        @formal_property_writee_module.include extmod::Module_Methods

        nil
      end

      def execute

        mod = @iambic_writer_method_writee_module
        box = @writable_formal_propery_method_names_box
        mod_ = @formal_property_writee_module

        init_edit_session_via_extended_included_client_module mod

        mod.const_set :Module_Methods, mod_  # :+#public-API (the name)
        mod.const_set :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___, box
        mod.instance_variable_set(
          :@entity_formal_property_method_nms_bx_for_wrt, box )

        mod.extend Extension_Module_Methods__

        mod.active_entity_edit_session = self
        mod.module_exec( & @edit_p )
        mod.active_entity_edit_session = nil

        finish mod
      end
    end

    class Class_Edit_Session__ < Module_Edit_Session__

      def initialize cls
        @iambic_writer_method_writee_module = cls
        cls.include Instance_Methods
        init_edit_session_via_extended_included_client_module cls
        @formal_property_writee_module = cls.singleton_class
        @writable_formal_propery_method_names_box =
          cls.entity_formal_property_method_names_box_for_write
      end
    end

    class Module_Edit_Session__

      private def init_edit_session_via_extended_included_client_module mod
        @method_added_filter = IDENTITY_
        @pay_attention_to_method_added = true
        @property_related_nonterminal = mod::Entity_Property.nonterminal_for self
        @ad_hoc_nonterminal_queue = mod::ENTITY_AD_HOCS___
        @nonterminal_queue = Adaptive_Nonterminal_Queue_.new(  # #note-330
          * @ad_hoc_nonterminal_queue,
          @property_related_nonterminal,
          Methodic_as_Nonterminal_[ self ] )
      end

      attr_reader :iambic_writer_method_writee_module  # for e.g p.stack

      attr_reader :property_related_nonterminal  # hax only (covered)

      def receive_edit st, & edit_p
        x = true
        if st.unparsed_exists
          pc = Parse_Context__.new st, self
          x = @nonterminal_queue.receive_parse_context pc
          if x && st.unparsed_exists
            x = when_after_process_iambic_fully_stream_has_content st
          end
        end
        if x
          if edit_p
            x = @iambic_writer_method_writee_module.module_exec( & edit_p )  # so result is user's result
          else
            x = @iambic_writer_method_writee_module  # so `[]` is wrappable
          end
        end
        x
      end

      def receive_parse_context pc
        # if this object added itself to the @nonterminal_queue, then this
        # method is where we receive calls to attempt to parse the stream.
        process_iambic_stream_passively pc.upstream
      end

    private

      # these are the iambic symbols exposed by the edit session itself,
      # that may mutate its state and/or affect its behavior

      def iambic_writer_method_name_suffix=
        against_iambic_property do | suffix_i |  # covered, :+#grease
          _RX = /\A.+(?=#{ ::Regexp.escape suffix_i }\z)/
          @method_added_filter = -> m_i, & oes_p do  # #experimetal
            md = _RX.match m_i
            if md
              md[ 0 ].intern
            else
              oes_p.call :error, :method_added_without_suffix do
                bld_method_added_without_suffix_event m_i, suffix_i
              end
            end
          end
          ACHIEVED_
        end
      end

      def ad_hoc_processor=
        @iambic_writer_method_writee_module.
          entity_ad_hocs_for_wrt.add_processor( iambic_property, iambic_property )
        ACHIEVED_
      end

      METHODIC_.cache_iambic_writer_methods self

    public

      def receive_metaproperty mprop
        @iambic_writer_method_writee_module.
          entity_property_class_for_write.class_exec( & mprop.apply )
      end

      def receive_method_added_name m_i
        if @pay_attention_to_method_added
          name_i = @method_added_filter.call m_i do | *, & ev_p |
            receive_invalid_propery ev_p[]
            UNABLE_
          end
          name_i and begin
            @property_related_nonterminal.
              finish_property_with_three false, m_i, name_i
          end
        end
      end

      def property_class  # :+#public-API
        @property_related_nonterminal.property_cls
      end

      def receive_new_property_cls x
        @property_related_nonterminal.receive_new_prop_cls x
      end

      def receive_property pr  # :+#public-API
        receive_prop pr
      end

      def receive_prop prop
        ok = true
        if prop.against_EC_p_a
          _ec = @iambic_writer_method_writee_module
          prop.against_EC_p_a.each do |p|
            ok = _ec.class_exec prop, & p
            ok or break
          end
        end
        ok and acpt_prop prop
      end

      def acpt_prop prop

        if prop.do_define_method
          while_ignoring_method_added do
            @iambic_writer_method_writee_module.send(
              :define_method,
              prop.iambic_writer_method_name,
              prop.iambic_writer_method_proc )
          end
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

      def while_ignoring_method_added
        befor = @pay_attention_to_method_added
        @pay_attention_to_method_added = false
        x = yield
        @pay_attention_to_method_added = befor
        x
      end

      def ignore_methods_added
        @pay_attention_to_method_added = false
      end

      def finish x
        if @property_related_nonterminal.last_incomplete_property
          pr = @property_related_nonterminal.last_incomplete_property
          maybe_send_event :error, :property_or_metaproperty_never_received_a_name do
            build_not_OK_event_with :property_or_metaproperty_never_received_a_name,
              :property_or_metaproperty, pr,
              :error_category, :argument_error
          end
        else
          x
        end
      end

    private

      def bld_method_added_without_suffix_event m_i, sfx
        build_not_OK_event_with :method_added_without_suffix,
            :method_name, m_i,
            :suffix, sfx,
            :error_category, :name_error do |y, o|

          y << "did not have expected suffix '#{ o.suffix }': #{
           }#{ ick o.method_name }"
        end
      end

      def receive_invalid_propery ev  # possible placeholder
        receive_event ev
      end

    public

      def maybe_receive_event * i_a, & ev_p
        receive_event ev_p[]
      end

      def receive_event ev
        raise ev.to_exception
      end

    private

      def maybe_send_event *, & ev_p  # #hook-OUT of [cb]
        raise ev_p[].to_exception
      end
    end

    # ~ the modules that enhance the extension modules or entity classes

    module Common_Module_Methods_

      def properties
        @properties ||= build_immutable_properties_stream_with_random_access_
      end

      def build_immutable_properties_stream_with_random_access_
        entity_formal_property_method_names_box_for_rd.to_value_scan.map_by do |i|
          send i
        end.immutable_with_random_access_keyed_to_method :name_i
      end

      def any_property_via_symbol i
        m_i = entity_formal_property_method_names_box_for_rd[ i ]
        m_i and send m_i
      end

      def property_via_symbol i
        send entity_formal_property_method_names_box_for_rd.fetch i
      end

      def method_added m_i
        if active_entity_edit_session
          @active_entity_edit_session.receive_method_added_name m_i
        end
        super
      end

      define_singleton_method :module_attr_reader_writer, MODULE_ATTR_READER_WRITER_METHOD__

      module_attr_reader_writer(
        :entity_ad_hocs_for_rd,
        :entity_ad_hocs_for_wrt,
        :ENTITY_AD_HOCS___,
        :@__entity_AHFW__ ) do |o|
          otr = o::ENTITY_AD_HOCS___
          if otr
            self._DO_ME
          else
            Entity_::Ad_Hoc_Processor__::Mutable_Nonterminal_Queue.new
          end
        end

      module_attr_reader_writer(
        :entity_formal_property_method_names_box_for_rd,
        :entity_formal_property_method_names_box_for_write,  # :+#public-API (name)
        :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___,
        :@entity_formal_property_method_nms_bx_for_wrt ) do |o|
          o::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___.dup
        end

      def entity_property_class_for_write
        @__entity_PCFW__ ||= begin
          new_cls = ::Class.new self::Entity_Property
          const_set :Entity_Property, new_cls
          @active_entity_edit_session.receive_new_property_cls new_cls
          new_cls
        end
      end

    private

      def o * x_a, & edit_p
        @active_entity_edit_session.receive_edit(
          Callback_::Iambic_Stream.via_array( x_a ), & edit_p )
      end

      def during_entity_normalize & p
        normz_for_wrt.push p ; nil
      end

      module_attr_reader_writer :normz_for_wrt, :ENTITY_NORM_P_A, :@ent_norm_p_a do |o|
        o::ENTITY_NORM_P_A ? o::ENTITY_NORM_P_A.dup : []
      end
    end

    module Extension_Module_Methods__

      include Common_Module_Methods_

      attr_accessor :active_entity_edit_session

      def [] cls, * rest
        if rest.length.nonzero?
          st = Callback_::Iambic_Stream.via_array rest
        end
        _enhance_to_and_edit_entity_class_via_any_nonempty_stream cls, st
      end

      def call cls, * rest, & edit_p
        if rest.length.nonzero?
          st = Callback_::Iambic_Stream.via_array rest
        end
        _enhance_to_and_edit_entity_class_via_any_nonempty_stream cls, st, & edit_p
      end

      def via_nonzero_length_arglist a, & edit_p
        st = Callback_::Iambic_Stream.via_array a
        cls = st.gets_one
        _enhance_to_and_edit_entity_class_via_any_nonempty_stream cls, st, & edit_p
      end

      def via & edit_p
        o = Extension_Module_Production_Session__.new( & edit_p )
        o.init_to_produce_extension_of_extension self
        o.execute
      end

    private

      def _enhance_to_and_edit_entity_class_via_any_nonempty_stream cls, st, & edit_p

        # when an edit block is passed, result is the result of the block.
        # otherwise, result is always the argument class to allow for
        # nested enhancement calls e.g if the call used the `[]` form

        _touch_extends_and_includes_on_client_class cls
        if edit_p || st
          cls.edit_entity_class do |sess|
            if st
              sess.receive_edit st, & edit_p
            else
              # for #grease, here is how you can fulfill only the block
              cls.module_exec( & edit_p )
            end
          end
        else
          cls
        end
      end

      def _touch_extends_and_includes_on_client_class cls
        if cls.respond_to? :edit_entity_class
          did_already = true
        else
          Callback_::Actor.methodic cls
          cls.extend Module_Methods__
        end
        cls.extend self::Module_Methods
        cls.include self
        if did_already
          _my_box = self::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___
          _their_box = cls.entity_formal_property_method_names_box_for_write
          _their_box.ensuring_same_values_merge_box! _my_box
        else
          cls.entity_formal_property_method_names_box_for_write  # copy them now
        end
        nil
      end
    end

    module Module_Methods__

      include Common_Module_Methods_

      attr_reader :active_entity_edit_session

      def edit_entity_class * x_a

        sess = Class_Edit_Session__.new self
        @active_entity_edit_session = sess

        if x_a.length.nonzero?
          x = sess.receive_edit Callback_::Iambic_Stream.via_array x_a
        end

        if block_given?
          x = yield sess
        end

        @active_entity_edit_session = nil
        sess.finish x
      end
    end

    module Instance_Methods

      ENTITY_AD_HOCS___ = nil

      ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___ = Callback_::Box.the_empty_box

      ENTITY_NORM_P_A = nil

      # Entity_Property = Property__ below

      def initialize * a, & p  # #experimental
        instance_exec( & p )
        super( * a, & nil )
      end

      def any_property_value_via_property prop
        if instance_variable_defined? prop.as_ivar
          instance_variable_get prop.as_ivar
        end
      end

      def property_value_via_property prop
        instance_variable_get prop.as_ivar
      end

      def receive_value_of_entity_property x, prop
        instance_variable_set prop.as_ivar, x
        ACHIEVED_
      end

    private

      def bound_properties
        @bp ||= Entity::Properties_Stack__::Bound_properties[
          method( :get_bound_property_via_property ), self.class.properties ]
      end

      def get_argument_via_property_symbol sym
        get_bound_property_via_property self.class.property_via_symbol sym
      end

      def get_bound_property_via_property prop
        had = true
        x = actual_property_box.fetch prop.name_i do
          had = false ; nil
        end
        Brazen_::Lib_::Trio[].new x, had, prop
      end

      def iambic_writer_method_name_passive_lookup_proc  # [cb] #hook-in
        bx = self.class.entity_formal_property_method_names_box_for_rd
        -> name_i do
          m_i = bx[ name_i ]
          if m_i
            self.class.send( m_i ).iambic_writer_method_name
          end
        end
      end

      def normalize
        ok = true
        p_a = self.class::ENTITY_NORM_P_A
        if p_a
          p_a.each do |p|
            ok = p[ self ]
            ok or break
          end
        end
        ok
      end
    end

    # ~ the property implementation

    class Property_Related_Nonterminal__

      include METHODIC_.iambic_processing_instance_methods

      def initialize * a
        @edit_session, @property_class = a
        @property_nonterminal = bld_property_nonterminal @property_class
        @adaptive_nonterminal_queue = Adaptive_Nonterminal_Queue_.new(
          @property_nonterminal,
          bld_metaproperty_nonterminal,
          Methodic_as_Nonterminal_[ self ] )
        @last_incomplete_property = nil
      end

      def property_cls
        @property_class
      end

      attr_reader :last_incomplete_property

      def receive_parse_context pc
        @adaptive_nonterminal_queue.receive_parse_context pc
      end

      def receive_new_prop_cls pcls
        @property_class = pcls
        new = bld_property_nonterminal pcls
        @adaptive_nonterminal_queue.replace_item @property_nonterminal, new
        @property_nonterminal = new
        nil
      end

    private

      def bld_metaproperty_nonterminal
        cls = MetaProperty__
        Nonterminal_.new do |pc|

          if cls.is_keyword pc.upstream.current_token
            st = pc.upstream
            d = st.current_index
            mprop = cls.via_iambic_stream st do |*|
              st.current_index = d
              false
            end
            if mprop
              @edit_session.receive_metaproperty mprop
            else
              KEEP_PARSING_
            end
          else
            KEEP_PARSING_
          end
        end
      end

      def bld_property_nonterminal pcls

        Nonterminal_.new do |pc|

          last_incomplete_prop = nil

          prop = if pcls.is_keyword pc.upstream.current_token
            st = pc.upstream
            d = st.current_index
            pcls.via_iambic_stream st do | i, * i_a, & ev_p |
              case i
              when :no_name
                if st.unparsed_exists && :meta_property == st.current_token
                  st.current_index = d
                else
                  last_incomplete_prop = ev_p[]
                end
                false  # NO PROP
              else
                @edit_session.maybe_receive_event i, * i_a, & ev_p
              end
            end
          end

          @last_incomplete_property = last_incomplete_prop
          if prop
            @edit_session.receive_prop prop
          else
            KEEP_PARSING_
          end
        end
      end

      def properties=
        st = @__methodic_actor_iambic_stream__
        ok = true
        while st.unparsed_exists
          ok = nil
          prop = @property_class.new do
            @name = Callback_::Name.via_variegated_symbol st.gets_one
            @iambic_writer_method_proc_is_generated = true
            @iwmn = via_name_build_internal_iambic_writer_meth_nm
            ok = normalize_property
          end
          ok &&= @edit_session.receive_prop prop
          ok or break
        end
        ok
      end

      def reuse=
        ok = true
        _prop_a = iambic_property
        _prop_a.each do | prop |
          ok = @edit_session.receive_prop prop
          ok or break
        end
        ok
      end

      METHODIC_.cache_iambic_writer_methods self

    public

      def finish_property_with_three proc_is_generated, meth_i, name_i
        if @last_incomplete_property
          cls = @last_incomplete_property
          @last_incomplete_property = nil
        else
          cls = @property_class
        end
        ok = nil
        prop = cls.new do
          @name = Callback_::Name.via_variegated_symbol name_i
          if proc_is_generated
            @iambic_writer_method_proc_is_generated = proc_is_generated
          else
            @iambic_writer_method_proc_is_generated = proc_is_generated
            @iambic_writer_method_proc_proc ||= nil
          end
          @iwmn = meth_i
          ok = normalize_property
        end
        ok and @edit_session.receive_prop prop
      end
    end

    class Property_or_MetaProperty__ < METHODIC_.simple_property_class

      METHODIC_.cache_iambic_writer_methods self, superclass do |h|
        h.delete :property  # this must not be in the syntax of metapropertiesk
        h
      end

      # ~ internal support

      def add_to_write_proc_chain & p
        if @iambic_writer_method_proc_is_generated
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = p
        else
          self._DO_ME
        end
        nil
      end
    end

    class MetaProperty__ < Property_or_MetaProperty__

    private

      def default=
        Entity_::Meta_Property__::Apply_default[ self, iambic_property ]
      end

      def entity_class_hook=
        Entity_::Meta_Property__::Apply_entity_class_hook[ self, iambic_property ]
      end

      def enum=
        Entity_::Meta_Property__::Apply_enum[ self, iambic_property ]
      end

      def property_hook=
        Entity_::Meta_Property__::Apply_property_hook[ self, iambic_property ]
      end

      def meta_property=
        @name = Callback_::Name.via_variegated_symbol iambic_property
        STOP_PARSING_
      end

    public

      # ~ internal support

      def apply
        p_a = aply_chain || [ dflt_apply ]
        mprop = self
        -> do
          ok = true
          p_a.each do |p|
            ok = instance_exec mprop, & p
            ok or break
          end
          ok
        end
      end

      attr_reader :aply_chain

      def against_property_class & p
        @aply_chain ||= [ dflt_apply ]
        @aply_chain.push p
        nil
      end

      def after_wrt & p
        @aftr_write_hooks ||= bld_and_init_after_write_hooks
        @aftr_write_hooks.push p
        nil
      end

      def bld_and_init_after_write_hooks
        before_p_p = if @iambic_writer_method_proc_is_generated
          @iambic_writer_method_proc_is_generated = false
          -> mprop do
            mprop.iambic_writer_method_proc_when_arity_is_one
          end
        else
          @iambic_writer_method_proc_proc
        end
        after_write_hook_p_a = []
        @iambic_writer_method_proc_proc = -> mprop do
          logic_p = before_p_p[ mprop ]
          -> do
            ok = instance_exec( & logic_p )
            if ok
              after_write_hook_p_a.each do |p|
                ok = p[ self ]
                ok or break
              end
            end
            ok
          end
        end
        after_write_hook_p_a
      end
      public :iambic_writer_method_proc_when_arity_is_one

      def dflt_apply
        -> mprop do
          name_i = mprop.name_i
          meth_i = :"#{ name_i }="
          _meth_p = mprop.iambic_writer_method_proc
          attr_reader name_i
          define_method meth_i, _meth_p
          private meth_i
          clear_iambic_writer_method_name_passive_proc
          KEEP_PARSING_
        end
      end

      Autoloader_[ Self_ = self ]
    end

    class Property__ < Property_or_MetaProperty__

      class << self

        def nonterminal_for edit_session
          Property_Related_Nonterminal__.new edit_session, self
        end
      end  # >>

      def description  # for [#074]
        if @name
          @name.as_variegated_symbol
        else
          '[ no name ]'
        end
      end

      def description_under expag
        if @name
          symbol = @name.as_variegated_symbol
          expag.calculate do
            code symbol
          end
        else
          Entity_::Small_Time_Actors__::Prop_desc_wonderhack[ expag, self ]
        end
      end

      def do_define_method
        @iambic_writer_method_proc_is_generated || @iambic_writer_method_proc_proc
      end

      def iambic_writer_method_name
        @iwmn
      end

      def new & p
        otr = dup
        otr.instance_exec( & p )
        otr.freeze
      end

      def any_value_of_metaprop mprop
        send mprop.name_i
      end

      def set_value_of_metaprop x, mprop
        instance_variable_set mprop.as_ivar, x
        nil
      end

      def against_EC_p_a  # :+#hook-over
      end

    private

      def property=
        x = super
        @iwmn ||= via_name_build_internal_iambic_writer_meth_nm
        x
      end

      def iambic_writer_method_proc_when_arity_is_one
        _NAME_I = name_i
        -> do
          _prop = self.class.send self.class.entity_formal_property_method_names_box_for_write.fetch _NAME_I
          receive_value_of_entity_property iambic_property, _prop  # RESULT VALUE
        end
      end

      def iambic_writer_method_proc_when_arity_is_zero
        _NAME_I = name_i
        -> do
          _prop = self.class.send self.class.entity_formal_property_method_names_box_for_write.fetch _NAME_I
          receive_value_of_entity_property true, _prop  # RESULT VALUE
        end
      end

    public  # ~ lib internal

      def via_name_build_internal_iambic_writer_meth_nm
        :"___entity_#{ @name.as_variegated_symbol }_iambic_writer___"
      end

      class << self

      private

        def during_property_normalize & p
          nrmlz_wrt.push p
          nil
        end

        define_singleton_method :module_attr_reader_writer, MODULE_ATTR_READER_WRITER_METHOD__

        module_attr_reader_writer :nrmlz_wrt, :NORM_P_A, :@nrmlz do |o|
          a = o::NORM_P_A
          if a
            a.dup
          else
            []
          end
        end
      end

      NORM_P_A = nil
    end

    module Instance_Methods
      Entity_Property = Property__  # as promised above
    end

    Entity_ = self
  end
end
