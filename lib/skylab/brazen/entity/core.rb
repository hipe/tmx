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

    MODULE_ATTR_READER_WRITER_METHOD__ = -> rd_i, wrt_i, _CONST, _IVAR, & bld_p do  # #note-065

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

    # ~ parsing support

    METHODIC_ = Callback_::Actor.methodic_lib

    # ~~ cacheing iambic writer methods #note-085

    module Cache_iambic_writer_methods__

      class << self

        def call top_class, upstream_class=top_class, & edit_hash_p

          top_class.class_exec do

            extend Cache_iambic_writer_methods__

            def iambic_writer_method_name_passive_lookup_proc  # [cb] hook-in
              self.class.iamb_writer_method_name_passive_proc
            end

            h = {}
            upstream_class.private_instance_methods( false ).each do | meth_i |
              md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
              md or next
              h[ md[ 0 ].intern ] = meth_i
            end

            if edit_hash_p
              h = edit_hash_p[ h ]
            end

            @iambic_writer_method_name_dictionary = h.freeze  # top class only
          end
          nil
        end

        alias_method :[], :call

      end  # >>

      # ~ courtesies

      def is_keyword i
        iambic_writer_method_name_dictionary.key? i
      end

      def clear_iambic_writer_method_name_passive_proc
        @iambic_writer_method_name_dictionary = nil
        @iambic_writer_method_name_passive_proc = nil
      end

      # ~ implementation

      def iamb_writer_method_name_passive_proc
        @iambic_writer_method_name_passive_proc ||= bld_iambic_writer_method_name_passive_proc
      end

      private def bld_iambic_writer_method_name_passive_proc
        h = iambic_writer_method_name_dictionary
        -> prop_i do
          h[ prop_i ]
        end
      end

      def iambic_writer_method_name_dictionary
        @iambic_writer_method_name_dictionary ||= bld_iambic_writer_method_name_dictionary
      end

      private def bld_iambic_writer_method_name_dictionary
        h = superclass.iambic_writer_method_name_dictionary.dup
        ( private_instance_methods( false ).each do | meth_i |
          md = IAMBIC_WRITER_METHOD_NAME_RX__.match meth_i
          md or next
          h[ md[ 0 ].intern ] = meth_i
        end )
        h.freeze
      end

      IAMBIC_WRITER_METHOD_NAME_RX__ = /\A.+(?==\z)/
    end

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

    class Adaptive_Nonterminal_Queue_

      def initialize * passive_parsers, & oes_p
        @on_event_selectively = oes_p
        @a = passive_parsers
      end

      def receive_parse_context pc

        # if any input exists, step thru each of the children in our queue
        # looking for any first child that consumes any input. if one such
        # child is found (and there is still more input) repeat the search
        # again from the first child in the queue. at any point, any child
        # may stop the entire parse completely. our boolean result is only
        # an indication of whether or not we ourselves wish to signal that
        # the parse stop (true means stay) and not if any parsing occurred

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

        # furthermore if a nonterminal consumed input and it was somewhere
        # other than the front of the queue, reorder the queue so that the
        # most recent winning non-terminal is always in front and the rest
        # are still in the same order with respect to each other.

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

      def initialize x_a, edit_session
        @edit_session = edit_session
        @upstream = Callback_::Iambic_Stream_.new 0, x_a
      end

      attr_reader :edit_session, :upstream
    end

    # ~ parsing the DSL: edit sessions for modules and classes

    class Module_Edit_Session__

      include METHODIC_.iambic_processing_instance_methods

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

    class Produce_extension_module__ < Module_Edit_Session__

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

    class Class_Edit_Session__ < Module_Edit_Session__

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

    class Module_Edit_Session__

      private def init_edit_session_via_extended_client_module mod
        mod.include Instance_Methods__
        @iambic_writer_method_writee_module = mod
        @method_added_filter = IDENTITY_
        @pay_attention_to_method_added = true
        @property_related_nonterminal = mod::Entity_Property.nonterminal_for self
        @ad_hoc_nonterminal_queue = mod::ENTITY_AD_HOCS___
        @nonterminal_queue = Adaptive_Nonterminal_Queue_.new(  # #note-115
          * @ad_hoc_nonterminal_queue,
          @property_related_nonterminal,
          Methodic_as_Nonterminal_[ self ] )
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

      Cache_iambic_writer_methods__[ self ]

    public

      def receive_metaproperty mprop
        mod = @iambic_writer_method_writee_module
        did_create_class = mod.entity_property_class_for_write.nil?
        pcls = mod.entity_property_class_for_wrt
        if did_create_class
          @property_related_nonterminal.receive_new_property_cls pcls
        end
        pcls.class_exec( & mprop.apply )
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

      def receive_prop prop

        if prop.do_define_method
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

      def receive_invalid_propery ev  # possible placeholder
        receive_event ev
      end
    end

    # ~ the modules that enhance the extension modules or entity classes

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

      module_attr_reader_writer(
        :entity_formal_property_method_names_box_for_rd,
        :entity_formal_property_method_names_box_for_wrt,
        :ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___,
        :@entity_formal_property_method_names_box_for_write ) do |o|
          o::ENTITY_FORMAL_PROPERTY_METHOD_NAMES_BOX___.dup
        end

      module_attr_reader_writer(
        :entity_property_class_for_rd,
        :entity_property_class_for_wrt,
        :Entity_Property,
        :@entity_property_class_for_write ) do |o|
          ::Class.new o::Entity_Property
        end

      attr_reader :entity_property_class_for_write

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
        @property_nonterminal = bld_property_nonterminal @property_class
        @adaptive_nonterminal_queue = Adaptive_Nonterminal_Queue_.new(
          @property_nonterminal,
          bld_metaproperty_nonterminal,
          Methodic_as_Nonterminal_[ self ] )
        @last_incomplete_property = nil
      end

      def receive_parse_context pc
        @adaptive_nonterminal_queue.receive_parse_context pc
      end

      def receive_new_property_cls pcls
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
            @iwmn = bld_iambic_writer_method_name_from_name
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

      Cache_iambic_writer_methods__[ self ]

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

      Cache_iambic_writer_methods__.call self, superclass do |h|
        h.delete :property  # this must not be in the syntax of metapropertiesk
        h
      end
    end

    class MetaProperty__ < Property_or_MetaProperty__

    private

      def default=
        Entity_::Meta_Property__::Apply_default[ self, iambic_property ]
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

      def add_to_write_proc_chain  & p
        if @iambic_writer_method_proc_is_generated
          @iambic_writer_method_proc_is_generated = false
          @iambic_writer_method_proc_proc = p
        else
          self._DO_ME
        end
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

    private

      def property=
        x = super
        @iwmn ||= bld_iambic_writer_method_name_from_name
        x
      end

      def bld_iambic_writer_method_name_from_name
        :"___entity_#{ @name.as_variegated_symbol }_iambic_writer___"
      end

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

      class << self

      private

        def during_normalize & p
          nrmlz_wrt.push p
          nil
        end

        define_singleton_method :module_attr_reader_writer, MODULE_ATTR_READER_WRITER_METHOD__

        module_attr_reader_writer :nrmlz_rd, :nrmlz_wrt, :NORM_P_A, :@nrmlz do |o|
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
          @hook_shell ||= MetaProperty__::Hook_Shell.new self
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

    end

    Entity_ = self

    KEEP_PARSING_ = true

    STOP_PARSING_ = false
  end
end
