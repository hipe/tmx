module Skylab::Fields

  module Entity  # [#001]

    class << self

      def call * a, & p
        _call_via_arglist p, a
      end

      def [] * a, & p
        _call_via_arglist p, a
      end

      def _call_via_arglist p, a
        call_by do |o|
          o.arglist = a
          o.block = p
        end
      end

      def call_by & p
        Session.call_by( & p )
      end
    end  # >>

    EXTMOD_CALL_METHOD__ = -> * x_a, & edit_p do

      Session.call_by do |o|
      o.arglist = x_a
      o.block = edit_p
      o.extmod = self
      end
    end

    EEC_METHOD__ = -> * a, & edit_p do

      Session.call_by do |o|
      o.client = self
      o.arglist = a
      o.block = edit_p
      end
    end

    Edit_client_class_via_argument_scanner_over_extmod = -> (
      cls, st, extmod
    ) do

      Session.call_by do |o|
      o.block = NIL_
      o.client = cls
      o.extmod = extmod
      o.upstream = st
      end
    end

    Apply_entity = -> extmod, arglist, & edit_p do

      Session.call_by do |o|
      o.arglist = arglist
      o.block = edit_p
      o.extmod = extmod
      end
    end

    class Session < Common_::MagneticBySimpleModel

      def initialize

        @_ad_hoc_processor_processor = nil
        @client = nil
        @extmod = nil
        @_floating = nil
        @_mprop_hooks_is_known_is_known = false

        @_optimism = [
          :_maybe_a_property_or_meta_property,
          :_maybe_a_builtin_term,
          :_maybe_an_ad_hoc
        ]

        @_writer_rx = nil
        yield self
      end

      def arglist= x_a
        @upstream = Common_::Scanner.via_array x_a
        x_a
      end

      attr_writer(
        :block,
        :client,
        :extmod,
        :upstream,
      )

      # (this class is too large. readers are wayy down #here)

      def execute  # assume upstream and block

        if @upstream.unparsed_exists
          if @block
            __when_args_and_block
          else
            __when_args_only
          end
        else
          @upstream = nil
          if @block
            __when_block_only
          else
            Here_
          end
        end
      end

      def __when_args_and_block

        _enter
        _process_block
        _exit
      end

      def __when_args_only

        _enter
        _exit
      end

      def __when_block_only

        if @client  # a re-open, or creating a "common properties" mod

          _enter
          _process_block
          _exit

        else  # make new or derived extension module

          @client = ::Module.new
          # ..
          _enter_module
          _process_block
          _exit

          @client
        end
      end

      def _enter

        if ! @client
          @client = @upstream.gets_one
        end

        if @client.respond_to? :superclass
          if @extmod
            __enter_class_against_extmod
          else
            __enter_class_bluesky
          end
          _any_args
        else
          _enter_module
        end
      end

      def _enter_module

        if @extmod
          __enter_module_against_extmod
        else
          __enter_module_bluesky
        end
        _any_args
      end

      def _any_args

        if @upstream
          if @upstream.unparsed_exists
            _process_remainder_of_upstream
          end
          @upstream = nil
        end
      end

      # ~~ ancestor chain & method definitions

      def __enter_class_against_extmod

        @client.include @extmod  # BEFORE DEFINE METHODS

        _maybe_gently_add_methods_to_class

        if @extmod.const_defined? :Module_Methods

          __xfer_properties_into_class
        end

        NIL_
      end

      def __enter_class_bluesky

        _maybe_gently_add_methods_to_class

        NIL_
      end

      def _maybe_gently_add_methods_to_class

        sess = self
        @client.class_exec do

          @___did_gently_add_methods_once ||= begin

             # because we don't have an ancestor chain checking this for us

             sess.__gently_define_class_methods

             ACHIEVED_
          end
        end
        NIL_
      end

      def __enter_module_against_extmod

        @client.include @extmod
        _maybe_extmod_methods
        __xfer_properties_into_module
        NIL_
      end

      def __enter_module_bluesky

        if ! @client.const_defined? :ENTITY_ENHANCEMENT_MODULE, false

          @client.const_set :ENTITY_ENHANCEMENT_MODULE, @client

          # #explanation-235
        end

        _maybe_extmod_methods

        NIL_
      end

      def _maybe_extmod_methods

        if @client.respond_to? :[]

          # e.g a common properties module already uses this & needs it

          if ! @client.respond_to? :properties

            @client.send :define_singleton_method,
              :properties, PROPERTIES_METHOD_FOR_MODULE__

            if ! @client.respond_to? :receive_entity_property
              @client.send :define_singleton_method,
                :receive_entity_property, RECV_ENT_PRP_METHOD__
            end
          end
        else
          @client.extend Extmod_Methods___
        end
      end

      # ~~ property transfer

      def __xfer_properties_into_class  # assume extmod has m.m

        @client.extend @extmod::Module_Methods

        prps = @client.properties
        if prps
          prps.merge_box! @extmod.properties
        else
          self._DONK
          # @client.properties
        end
        NIL_
      end

      def __xfer_properties_into_module

        if @extmod.const_defined? :Module_Methods

          @client.properties.merge_box! @extmod.properties

          @client::Module_Methods.include @extmod::Module_Methods
        end
        NIL_
      end

      define_method :__gently_define_class_methods, ( -> do

        # #explanation-290

        # ~ mm
        eec = :edit_entity_class
        rep = :receive_entity_property
        # ~ im
        fps = :formal_properties
        ppsf = :process_argument_scanner_fully
        ppsp = :process_argument_scanner_passively
        rpp = :receive_polymorphic_property
        gopv = :gets_one_polymorphic_value

        -> do

          @client.class_exec do

            define_singleton_method :properties, PROPERTIES_METHOD_FOR_CLASS___
              # (trump any existing one)

            if ! respond_to? eec
              define_singleton_method eec, EEC_METHOD__
            end

            if ! respond_to? rep
              define_singleton_method rep, RECV_ENT_PRP_METHOD__
            end

            # ~ im

            if ! method_defined? fps
              define_method fps, FORMAL_PRPS_METHOD__
            end

            if ! method_defined? rpp
              define_method rpp, RPP_METHOD___
            end

            if ! private_method_defined? ppsf
              define_method ppsf, DEFINITION_FOR_THE_METHOD_CALLED_PROCESS_POLYMORPHIC_STREAM_FULLY
            end

          private

            if ! private_method_defined? ppsp
              define_method ppsp, DEFINITION_FOR_THE_METHOD_CALLED_PROCESS_POLYMORPHIC_STREAM_PARTIALLY
            end

            if ! private_method_defined? gopv
              define_method gopv, GOPV_METHOD___
            end

            NIL_
          end  # end class exec
        end  # end method p
      end ).call

      def _process_block

        if ! @client.respond_to? :method_added
          did_define = true
          __define_DSL_methods
        end

        @client.instance_variable_set :@entity_edit_session, self
        @client.module_exec( & @block )
        @client.instance_variable_set :@entity_edit_session, nil

        if did_define

          # because of the OCD (reasonably so?) of wanting to
          # avoid the superfluous calls to our handler:

          @client.singleton_class.send :remove_method, :method_added
        end
        NIL_
      end

      def __define_DSL_methods

        @client.module_exec do
          define_singleton_method :method_added, METHOD_ADDED_METHOD___
          define_singleton_method :o, O_METHOD___
        end
      end

      # ~ argument session ( could be its own session )

      def __receive_iambic x_a

        @upstream and self._SANITY
        @upstream = Common_::Scanner.via_array x_a
        _process_remainder_of_upstream
        NIL_
      end

      def _process_remainder_of_upstream  # assume at least one. #note-185

        did = nil
        m = nil
        st = @upstream

        h = {

          _maybe_a_property_or_meta_property: -> do

            pcls = property_class  # renew this at every step, in case mprops

            if pcls.private_method_defined? m
              did = true
              prp_ = pcls.__consume_from self
              if prp_._is_meta_property
                __receive_meta_property prp_
              else
                __session_receive_property prp_
              end
            else
              KEEP_PARSING_
            end
          end,

          _maybe_a_builtin_term: -> do

            cls = self.class

            -> do

              if cls.private_method_defined? m
                did = true
                st.advance_one
                send m
              else
                KEEP_PARSING_
              end
            end
          end.call,

          _maybe_an_ad_hoc: -> do

            ahp = nil

            -> do

              ahp ||= ( @___ahp ||= Here_::AdHocProcessor_::Processors.new self )

              d_ = st.current_index
              kp_ = ahp.consume_passively
              did = d_ != st.current_index
              kp_
            end
          end.call,
        }

        a = @_optimism
        d = 0
        last = a.length - 1
        m = :"#{ st.head_as_is }="

        begin

          did = nil
          kp = ( h.fetch a.fetch d ).call
          if did

            if st.no_unparsed_exists  # the only way you get out of here OK
              @upstream = nil
              break
            end

            if ! kp  # a nonterminal wants to stop ALL parsing now (ick)
              break
            end

            m = :"#{ st.head_as_is }="

            if d.zero?  # the first nonterminal matched normally
              redo
            end

            # whatever nonterminal matched, re-sort so this is at front

            hot = a.fetch d
            a[ d, 1 ] = EMPTY_A_
            a.unshift hot
            d = 0
            redo
          end

          if last == d  # none of the nonterminals matched. leave now.
            break
          end

          d += 1  # try the next nonterminal
          redo
        end while nil

        if ! did
          raise Home_::ArgumentError, "unrecognized property '#{ st.head_as_is }'"
        end
        kp
      end

    private

      # ~~

      def ad_hoc_processor=

        ahpp = @_ad_hoc_processor_processor
        if ! ahpp
          ahpp = Here_::AdHocProcessor_::ProcessorProcessor.new self
          @_ad_hoc_processor_processor = ahpp
        end
        ahpp.consume
      end

      def polymorphic_writer_method_name_suffix=

        if @upstream.unparsed_exists

          s = @upstream.gets_one
          @_writer_rx = /\A(?<variegated>.+)#{ ::Regexp.escape s }\z/
          @_expected_suffix = s
          KEEP_PARSING_
        else
          raise Home_::ArgumentError, _say_expected_value_for_here
        end
      end

      def property=

        add_property_with_variegated_name @upstream.gets_one
      end

      def properties=

        kp = nil
        st = @upstream
        begin
          kp = add_property_with_variegated_name st.gets_one
          kp or break
          if st.unparsed_exists
            redo
          end
          break
        end while nil
        kp
      end

      def reuse=

        kp = true

        _prp_a = @upstream.gets_one

        _prp_a.each do | prp |

          kp = _receive_complete_property prp
          kp or break
        end
        kp
      end

      def property_object=

        _receive_complete_property @upstream.gets_one
      end

    public

      def _say_expected_value_for_here

        _a = caller_locations 1, 1
        _m = _a.first.base_label[ 0 .. -2 ]
        "expecting a value for '#{ _m }'"
      end

      # ~ properties ( creating & accepting )

      def __receive_method_added m

        if @_writer_rx
          md = @_writer_rx.match m
          if md
            _accept_method_added md, m
          else
            raise ::NameError, __say_expected_suffix( m )
          end
        else
          _accept_method_added m
        end
      end

      def __say_expected_suffix m
        "did not have expected suffix '#{ @_expected_suffix }': '#{ m }'"
      end

      def _accept_method_added md=nil, m

        sym = if md
          md[ :variegated ].intern
        else
          m
        end

        if @_floating
          flot = @_floating
          @_floating = nil
        end

        sess = self
        same = -> do
          @name = Common_::Name.via_variegated_symbol sym
          @custom_polymorphic_writer_method_name = m
          sess._shake_it_up self
          normalize_property
        end

        if flot

          prp = flot.dup
          prp.instance_exec do
            instance_exec( & same )
            freeze
          end
        else
          prp = property_class.new_by do
            instance_exec( & same )
          end
        end

        _receive_complete_property prp
      end

      def add_property_with_variegated_name sym

        sess = self
        _prp = property_class.new_by do

          @name = Common_::Name.via_variegated_symbol sym
          sess._shake_it_up self
          normalize_property
        end

        _receive_complete_property _prp
      end

      def _shake_it_up prp

        if ! prp._is_meta_property

          if prp.name
            prp._shibboleth = :"__#{ prp.name.as_variegated_symbol }__property"
          end

          @_mprop_hooks_is_known_is_known || __know_mprop_hooks
          if @_prop_normalizer
            @_prop_normalizer.normalize_mutable_property prp
          end
        end

        NIL_
      end

      def __know_mprop_hooks

        @_mprop_hooks_is_known_is_known = true

        cls = property_class
        if cls.const_defined? METAPROPERTIES_WITH_HOOKS_
          @_prop_normalizer = Here_::MetaProperty::PropertyNormalizer.new self
        else
          @_prop_normalizer = false
        end
        NIL_
      end

      def property_class
        @__pcls ||= __determine_property_class
      end

      def __determine_property_class
        if @client.const_defined? :Property
          @client.const_get :Property
        else
          Property
        end
      end

      def pcls_changed

        @_mprop_hooks_is_known_is_known = false
        @_prop_normalizer = nil
        @__pcls = nil
      end

      def __session_receive_property prp

        if prp.name
          @_floating and self._SANITY
          _receive_complete_property prp
        else
          @_floating = prp
          KEEP_PARSING_
        end
      end

      def _receive_complete_property prp

        @client.properties.__box_receive_property prp
        @client.receive_entity_property prp
      end

      def __receive_meta_property prp

        ( @___mpp ||= Here_::MetaProperty::Processor.new self ) << prp

        KEEP_PARSING_
      end

      def _exit

        if @_floating
          raise Home_::ArgumentError, __say_floating
        end

        NIL_
      end

      def __say_floating

        _s = Here_::Moniker_via_Property[ @_floating ]

        "property or metaproperty never received a name - #{ _s }"
      end

      attr_reader(  # :#here
        :client,
        :upstream,
      )
      alias_method :downstream, :client  # for now
    end

    # ~ module methods (some)

    PROPERTIES_METHOD_FOR_CLASS___ = -> do
      @properties ||= Build_properties_box__.__for_class self
    end

    PROPERTIES_METHOD_FOR_MODULE__ = -> do
      @properties ||= Build_properties_box__.__for_module self
    end

    module Build_properties_box__ ; class << self  # #explanation-735

      def __for_class cls

        sc = cls.superclass

        if sc.respond_to? :properties
          otr = sc.properties  # might be stub method from base class
        end

        if otr
          otr = otr.dup
          otr.__init_copy cls, cls.singleton_class
          otr
        else
          _new_box cls, cls.singleton_class
        end
      end

      def __for_module client

        if client.const_defined? :Module_Methods

          mm = client::Module_Methods

          if ! client.const_defined? :Module_Methods, false

            mm_ = ::Module.new
            mm_.include mm
            client.const_set :Module_Methods, mm_
            mm = mm_
          end
        else
          mm = ::Module.new
          client.const_set :Module_Methods, mm
        end

        rmod = ::Module.new
        client.const_set :READER_SINGLETON_FOR_EXTENSION_MODULE___, rmod
        rmod.extend mm

        _new_box rmod, mm
      end

      def _new_box rmod, wmod
        Property_Box___.new rmod, wmod
      end
    end ; end

    O_METHOD___ = -> * x_a do

      block_given? and raise ::ArgumentError

      @entity_edit_session.__receive_iambic x_a
      NIL_
    end

    METHOD_ADDED_METHOD___ = -> m do

      sess = @entity_edit_session
      if sess
        sess.__receive_method_added m
      end
      NIL_
    end

    RECV_ENT_PRP_METHOD__ = -> prp do
      KEEP_PARSING_
    end

    module Extmod_Methods___

      define_method :call, EXTMOD_CALL_METHOD__
      define_method :[], EXTMOD_CALL_METHOD__

      define_method :properties, PROPERTIES_METHOD_FOR_MODULE__
      define_method :receive_entity_property, RECV_ENT_PRP_METHOD__
    end

    # ~ instance methods

    RPP_METHOD___ = -> prp do  # "receive polymorphic property"

      case prp.argument_arity
      when :one
        instance_variable_set prp.ivar, gets_one_polymorphic_value
      when :zero
        instance_variable_set prp.ivar, true
      else
        self._COVER_ME
      end
      KEEP_PARSING_
    end

    FORMAL_PRPS_METHOD__ = -> do  # the instance method
      self.class.properties
    end

    GOPV_METHOD___ = -> do  # "gets one polymorphic value"
      @_polymorphic_upstream_.gets_one
    end

    # ~ models

    class Property_Box___

      def initialize rmod, wmod

        @_a = [] ; @_h = {}
        @_rmod = rmod ; @_wmod = wmod
      end

      def initialize_copy _

        @_a = @_a.dup ; @_h = @_h.dup
        @_rmod = @_wmod = nil
      end

      def __init_copy rmod, wmod
        @_rmod = rmod ; @_wmod = wmod
        NIL_
      end

      # ~ conversion operations

      def to_mutable_box_like_proxy
        to_new_mutable_box_like_proxy
      end

      def to_new_mutable_box_like_proxy

        bx = Common_::Box.new
        to_value_stream.each do | prp |
          bx.add prp.name_symbol, prp
        end
        bx
      end

      # ~ reduce operations

      def length
        @_a.length
      end

      def has_key k
        @_h.key? k
      end

      def [] k
        fetch k do end
      end

      def at_offset d  # no block
        fetch @_a.fetch d
      end

      def fetch k

        shib = @_h[ k ]
        if shib
          @_rmod.send shib
        elsif block_given?
          yield
        else
          raise ::KeyError, "key not found: '#{ k }'"
        end
      end

      def group_by & p
        h = {}
        each_value do | x |
          k = p[ x ]
          h.fetch k do
            h[ k ] = []
          end.push x
        end
        h
      end

      def reduce_by & p
        to_value_stream.reduce_by( & p )
      end

      def at * k_a
        k_a.map( & method( :fetch ) )
      end

      # ~ map operations & support

      def get_keys
        @_a.dup
      end

      def a_
        @_a
      end

      def each_key( & x_p )
        @_a.each( & x_p )
      end

      def each_value
        if block_given?
          to_value_stream.each do | prp |
            yield prp
          end
        else
          enum_for :each_value
        end
      end

      def to_value_stream

        a = @_a ; mod = @_rmod ; d = -1 ; h = @_h ; last = a.length - 1

        Common_.stream do
          if d != last
            d += 1
            mod.send h.fetch a.fetch d
          end
        end
      end

      # ~ mutators

      def remove k  # :+#by:tm
        x = @_h.fetch k
        @_h.delete k
        @_a[ @_a.index( k ), 1 ] = EMPTY_A_
        x
      end

      def merge_box! otr

        a = @_a ; h = @_h
        h_ = otr._h
        otr._a.each do | sym |
          h.fetch sym do
            a.push sym
            h[ sym ] = h_.fetch sym
            NIL_
          end
        end
        NIL_
      end

      protected
      attr_reader :_a, :_h
      public

      def __box_receive_property prp

        k = prp.name.as_variegated_symbol
        shib = prp._shibboleth

        @_h.fetch k do
          @_a.push k
          @_h[ k ] = shib
          NIL_
        end

        @_wmod.send :define_method, shib do
          prp
        end

        NIL_
      end
    end

    class Property  # < Home_::SimplifiedName (no reason to)

      class << self

        def new_with * x_a
          # (rather than bring in the m.m of [#fi-016] whole hog, cherry-pick)
          kp = true
          prp = new_by do
            kp = process_iambic_fully x_a
            kp &&= normalize_property
          end
          if kp
            prp
          else
            self._BUILD_FAILED
          end
        end

        def __consume_from sess

          # don't propagate kp here - it is used to stop when
          # the name is reached, not to signal an error state

          new_by do
            process_argument_scanner_passively sess.upstream
            sess._shake_it_up self
            normalize_property
          end
        end

        alias_method :new_by, :new  # [ba]
        undef_method :new
      end  # >>

      def initialize & edit_p
        @argument_arity = :one
        @name = nil
        @parameter_arity = :zero_or_one  # in contrast to [#fi-016]
        instance_exec( & edit_p )
        freeze
      end

      include Home_::Attributes::Actor::InstanceMethods

      # ~ description (for [#ca-010])

      def description
        if @name
          @name.as_variegated_symbol
        else
          '[ no name ]'
        end
      end

      def description_under expag
        nm = @name
        if nm
          expag.calculate do
            code nm.as_variegated_symbol
          end
        else
          Here_::Moniker_via_Property[ expag, self ]
        end
      end

      # ~ name & related

      def conventional_polymorphic_writer_method_name
        :"#{ @name.as_variegated_symbol }="
      end

      attr_reader :custom_polymorphic_writer_method_name

      def ivar  # override parent
        @name.as_ivar
      end

      def name_function
        @name
      end

      def set_polymorphic_writer_method_name x
        @custom_polymorphic_writer_method_name = x
        NIL_
      end

      attr_accessor :_shibboleth

      # ~~ normalization API

      def knownness_via_association_ prp  # #[#fi-029]

        ivar = prp.ivar

        if instance_variable_defined? ivar
          Common_::Known_Known[ instance_variable_get ivar ]
        else
          Common_::KNOWN_UNKNOWN
          # raise ::NameError, __say_no_ivar( ivar )
        end
      end

      def normalize_qualified_knownness qkn, & x_p  # :+[#ba-027] assume some normalizer (for now)

        Home_::Attributes::Normalization_Against_Model[ qkn, self, & x_p ]
      end

      def is_normalizable__

        if Has_default[ self ]
          ACHIEVED_
        elsif ad_hoc_normalizer_box
          ACHIEVED_
        elsif __parameter_arity_object.begin.nonzero?
          ACHIEVED_
        end
      end

      attr_reader :ad_hoc_normalizer_box

      def prepend_ad_hoc_normalizer_ & arg_and_oes_and_block_p

        bx = _touch_AHN_box
        _d = bx.length
        bx.add_to_front _d, arg_and_oes_and_block_p
        NIL_
      end

      def append_ad_hoc_normalizer_ & arg_and_oes_and_block_p

        bx = _touch_AHN_box
        _d = bx.length
        bx.add _d, arg_and_oes_and_block_p
        NIL_
      end

      def _touch_AHN_box

        @ad_hoc_normalizer_box ||= Common_::Box.new
      end

      def set_value_of_formal_property_ x, prp

        # this is actually for setting a *meta*property value on the property!

        instance_variable_set prp.ivar, x
        KEEP_PARSING_
      end

      ## ~~ default (a meta-meta property & part of the normalization API)

      def new_without_default
        new_with_default
      end

      def new_with_default & default_x_p
        prp = dup
        prp._set_default_proc( & default_x_p )
        prp.freeze  # not for sure
      end

      def default_value_via_entity_ entity_x

        if @default_proc.arity.zero?
          @default_proc[]
        else
          @default_proc[ entity_x ]
        end
      end

      def default=
        x = gets_one_polymorphic_value
        _set_default_proc do
          x
        end
      end

      def default_proc=
        _set_default_proc( & gets_one_polymorphic_value )
      end

      def set_default_proc & p
        _set_default_proc( & p )
        self
      end

      def _set_default_proc & p
        if block_given?
          @default_proc = p
        else
          remove_instance_variable :@default_proc
        end
        KEEP_PARSING_
      end

      attr_reader :default_proc

      ## ~~ enum (a meta-meta-property & indirectly part of the normalization API)

      attr_reader :enum_box

      def enum=

        bx = Common_::Box.new
        _x_a = gets_one_polymorphic_value

        _x_a.each do | x |
          bx.add x, nil
        end

        @enum_box = bx.freeze

        _touch_AHN_box.touch :__enum__ do
          Home_::MetaAttributes::Enum::Normalize_via_qualified_known
        end

        KEEP_PARSING_
      end

      # ~~ mutate entity (a meta-meta-property, and hook. maybe [#sl-134] island)

      attr_reader :mutate_entity_proc_

      def mutate_entity=

        @argument_arity = :custom
        @mutate_entity_proc_ = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      ## ~~ parameter arity (a meta-meta property & part of the n11n API)

      def required=
        @parameter_arity = :one
        KEEP_PARSING_
      end

      def parameter_arity=
        @parameter_arity = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def __parameter_arity_object
        Parameter_arity_space___[].fetch @parameter_arity
      end

      Parameter_arity_space___ = Lazy_.call do

        # (for better regressions we load this late)

        x = Here_::MetaMetaMetaProperties::Arity::Space.create do
          self::ZERO_OR_ONE = new 0, 1
          self::ONE = new 1, 1
        end
        Parameter_Arity_Space____ = x
        x
      end

      def parameter_arity
        @parameter_arity  # (hi.)
      end

      # ~~ argument arity

      def argument_arity=
        x = gets_one_polymorphic_value
        if :custom == x
          @has_custom_polymorphic_writer_method = true
          @polymorphic_writer_method_proc_proc = nil
        end
        @argument_arity = x
        KEEP_PARSING_
      end

      def argument_arity
        @argument_arity  # (hi.)
      end

      attr_reader(
        :has_custom_polymorphic_writer_method,
        :polymorphic_writer_method_proc_proc,
      )

      # ~~ syntactic finishing of the parse

      def property=

        @name = Common_::Name.via_variegated_symbol gets_one_polymorphic_value
        STOP_PARSING_
      end

      def meta_property=

        @_is_meta_property = true

        sym = gets_one_polymorphic_value
        @name = Common_::Name.via_variegated_symbol sym

        STOP_PARSING_
      end

      attr_reader :_is_meta_property

      def normalize_property  # ~ your last hookpoint before freezing
        ACHIEVED_
      end

      def name_symbol
        @name.as_variegated_symbol
      end

      def name
        @name  # can be nil; (hi.)
      end

      private(
        :argument_arity=,
        :default=,
        :default_proc=,
        :enum=,
        :meta_property=,
        :mutate_entity=,
        :parameter_arity=,
        :property=,
        :required=,
      )
    end

    # ==

    CONST_SEP_ = Common_::CONST_SEPARATOR
    Here_ = self
    METAPROPERTIES_WITH_HOOKS_ = :METAPROPERTIES_WITH_HOOKS___

    # ==
  end
end
# #tombstone-B: re-housed from [br] to [fi]
# :+#tombsone: class for #note-185 self-adapting syntax
