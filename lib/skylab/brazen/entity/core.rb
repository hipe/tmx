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
            sess.receive_edit x_a[ 1 .. -1 ], & edit_p
          end
        end
      end
    end

    # ~ parsing the DSL: edit sessions for modules and classes

    METHODIC_ = Callback_::Actor.methodic_lib

    module Edit_Session_Methods__

      include METHODIC_.iambic_processing_instance_methods

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
        init_edit_session_via_extended_client_module mod
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
        init_edit_session_via_extended_client_module cls
        @formal_property_writee_module = cls.singleton_class
        @writable_formal_propery_method_names_box =
          cls.entity_formal_property_method_names_box_for_wrt
      end

      def finish
        nil
      end
    end

    module Edit_Session_Methods__

      private def init_edit_session_via_extended_client_module mod
        mod.include Instance_Methods__
        @iambic_writer_method_writee_module = mod
        @method_added_filter = IDENTITY_
        @pay_attention_to_method_added = true
        @property_related_nonterminal = mod::Entity_Property.nonterminal_for self
        @ad_hoc_nonterminal_queue = mod::ENTITY_AD_HOCS___
        @nonterminal_queue = Non_Terminal_Queue_.new(  # #note-115
          * @ad_hoc_nonterminal_queue,
          @property_related_nonterminal,
          self )
      end

      attr_reader :property_related_nonterminal  # hax only (covered)

      def receive_edit x_a, & edit_p
        x = true
        if x_a.length.nonzero?
          pc = Parse_Context__.new x_a, self
          st = pc.upstream
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

    public

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

      def receive_prop_two do_define_method, prop

        if do_define_method
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

      def maybe_send_event *, & ev_p  # #hook-out [cb]
        raise ev_p[].to_exception
      end

      def receive_invalid_propery ev  # possible placeholder
        raise ev.to_exception
      end
    end

    # ~~ in support of the above module

    class Non_Terminal_Queue_

      include METHODIC_.iambic_processing_instance_methods

      def initialize * passive_parsers, & oes_p
        @on_event_selectively = oes_p
        @a = passive_parsers.freeze
        freeze
      end

      def receive_parse_context pc

        # if any input exists, step thru each of the children in our queue
        # looking for any first child that consumes any input. if one such
        # child is found (and there is still more input) repeat the search
        # again from the first child in the queue. at any point, any child
        # may stop the entire parse completely. our boolean result is only
        # an indication of whether or not we ourselves wish to signal that
        # the parse stop (true means stay); and not if any parsing occured

        ok = true
        stream = pc.upstream
        while stream.unparsed_exists
          d = stream.current_index
          stream_is_same = true
          @a.each do |cx|
            ok = cx.receive_parse_context pc
            ok or break
            if d != stream.current_index
              stream_is_same = false
              break
            end
          end
          stream_is_same and break
        end
        ok
      end
    end

    class Parse_Context__

      def initialize x_a, edit_session
        @edit_session = edit_session
        @upstream = Callback_::Iambic_Stream_.new 0, x_a
      end

      attr_reader :edit_session, :upstream
    end

    # ~ the modules that enhance the extension modules or entity classes

    MODULE_ATTR_READER_WRITER_METHOD__ = -> rd_i, wrt_i, _CONST, _IVAR, & bld_p do  # #note-320

      define_method rd_i do
        const_get _CONST
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
      end

      nil
    end

    module Common_Module_Methods__

      def properties
        entity_formal_property_method_names_box_for_rd.to_value_scan.map_by do |i|
          send i
        end.immutable_with_random_access_keyed_to_method :name_i
      end

      def method_added m_i
        if active_entity_edit_session
          @active_entity_edit_session.receive_method_added_name m_i
        end
        super
      end

      define_singleton_method :module_attr_reader_writer, MODULE_ATTR_READER_WRITER_METHOD__

      module_attr_reader_writer(
        :entity_formal_property_method_names_box_for_rd,
        :entity_formal_property_method_names_box_for_wrt,
        :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___,
        :@entity_formal_property_method_names_box_for_write ) do |o|

          o::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___.dup

        end

      module_attr_reader_writer(
        :entity_ad_hocs_for_rd,
        :entity_ad_hocs_for_wrt,
        :ENTITY_AD_HOCS___,
        :@entity_ad_hocs_for_write ) do |o|

          otr = o::ENTITY_AD_HOCS___
          if otr
            self._DO_ME
          else
            Entity_::Ad_Hoc_Processor__::Mutable_Nonterminal_Queue.new
          end
        end

    private

      def o * x_a, & edit_p
        if active_entity_edit_session
          sess = @active_entity_edit_session
        else
          self._DO_ME
        end
        sess.receive_edit x_a, & edit_p
      end
    end

    module Extension_Module_Methods__

      include Common_Module_Methods__

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

    module Module_Methods__

      include Common_Module_Methods__

      attr_reader :active_entity_edit_session

      def entity_edit_sess
        sess = Class_Edit_Session__.new self
        @active_entity_edit_session = sess
        x = yield sess
        sess.finish
        @active_entity_edit_session = nil
        x
      end
    end

    module Instance_Methods__

      ENTITY_AD_HOCS___  = nil

      ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___ = Callback_::Box.the_empty_box

      # Entity_Property = Property__ below

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

    # ~ the property implementation

    class Property_Related_Nonterminal__

      include METHODIC_.iambic_processing_instance_methods

      def initialize * a
        @edit_session, @property_class = a
      end

      def receive_parse_context pc
        process_iambic_stream_passively pc.upstream
      end

      def iambic_writer_method_name_passive_lookup_proc  # #hook-in
        super_p = super
        -> prop_i do
          m_i = super_p[ prop_i ]
          if ! m_i
            #todo - look for metaproperties here
          end
          m_i
        end
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
        _do_define_method = true
        _meth_i = :"___entity_#{ name_i }_iambic_writer___"
        finish_property_with_three _do_define_method, _meth_i, name_i
      end

      def reuse=
        ok = true
        _prop_a = iambic_property
        _prop_a.each do | prop |
          ok = @edit_session.receive_prop_two :do_define_method, prop
          ok or break
        end
        ok
      end

    public

      def finish_property_with_three do_define_method, meth_i, name_i
        _prop = @property_class.new do
          @name = Callback_::Name.via_variegated_symbol name_i
          @iwmn = meth_i
        end
        @edit_session.receive_prop_two do_define_method, _prop
      end
    end

    IAMBIC_WRITER_METHOD_NAME_RX__ = /\A.+(?==\z)/

    class Property____ < METHODIC_.simple_property_class

      class << self
        attr_reader :iamb_writer_method_name_dictionary
      end

      h = {}
      superclass.private_instance_methods( false ).each do |meth_i|
        md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
        md or next
        h[ md[ 0 ].intern ] = meth_i
      end

      @iamb_writer_method_name_dictionary = h.freeze
    end

    class Property__ < Property____

      class << self

        def nonterminal_for edit_session
          Property_Related_Nonterminal__.new edit_session, self
        end

      # ~ internal

        def iamb_writer_method_name_passive_proc
          @iamb_writer_method_name_passive_proc ||=
            bld_iambic_writer_method_name_passive_proc
        end

      private

        def bld_iambic_writer_method_name_passive_proc
          h = iamb_writer_method_name_dictionary
          -> prop_i do
            h[ prop_i ]
          end
        end

        def iamb_writer_method_name_dictionary
          @iamb_writer_method_name_dictionary ||= -> do
            _h = super.dup
            self._DO_ME
          end
        end
      end

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

      def iambic_writer_method_name_passive_lookup_proc
        self._RIDE_ME
        self.class.iamb_writer_method_name_passive_proc
      end
    end

    module Instance_Methods__
      Entity_Property = Property__  # as promised above
    end

    if false

      # WAS: read [#001] the entity enhancement narrrative

    READ_BOX__ = :PROPERTIES_FOR_READ__
    WRITE_BOX__ = :PROPERTIES_FOR_WRITE__

    class Scope_Kernel__  # formerly "flusher"

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

      def f_inish_property
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

    class P_roperty__

      def initialize *a
        a.length.nonzero? and set_prop_i_and_iambic_writer_method_name( * a )
        notificate :at_end_of_process_iambic
        block_given? and yield self
        freeze
      end

      def description
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

    KEEP_PARSING_ = true

    Entity_ = self
  end
end
