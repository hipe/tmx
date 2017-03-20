require 'skylab/common'

module Skylab::Fields

  # (a new file created after dissolution of [m-h] - has little history. see [#001])

  class << self

    def from_methods * i_a, & defn_p
      Home_::From_Methods___.call_via_arglist i_a, & defn_p
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  # ==

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_PROCESS_POLYMORPHIC_STREAM_FULLY = -> scn, & p do

    # (migrated from [br]. better fit here but may be legacy.)

    kp = process_argument_scanner_passively scn, & p

    if ! kp || scn.no_unparsed_exists
      kp
    else

      ev = Home_::Events::Extra.with :unrecognized_token, scn.head_as_is

      if respond_to? :receive_extra_values_event
        receive_extra_values_event ev
      else
        raise ev.to_exception
      end
    end
  end

  # ~

  DEFINITION_FOR_THE_METHOD_CALLED_PROCESS_POLYMORPHIC_STREAM_PARTIALLY = -> scn, & p do

    # (import from [br]. probably legacy.) make it private.

    kp = KEEP_PARSING_ ; bx = formal_properties

    if scn.unparsed_exists

      bx ||= MONADIC_EMPTINESS_

      instance_variable_set :@_argument_scanner_, scn

      begin

        k = scn.head_as_is

        prp = bx[ k ]
        prp || break

        scn.advance_one

        m = prp.custom_argument_scanning_writer_method_name

        kp = if m
          send m
        else
          _parse_association_ prp, & p
        end

        kp || break

        scn.no_unparsed_exists ? break : redo
      end while above

      remove_instance_variable :@_argument_scanner_
    end
    kp
  end

  DEFINITION_FOR_THE_METHOD_CALLED_WRITE_VIA_ASSOCIATION_ = -> x, asc do
    instance_variable_set asc.as_ivar, x
    KEEP_PARSING_  # these writes cannot fail gracefully. this is as convenience
  end

  DEFINITION_FOR_THE_METHOD_CALLED_READ_KNOWNNESS_ = -> asc do

    ivar = asc.as_ivar

    if instance_variable_defined? ivar
      Common_::Known_Known[ instance_variable_get ivar ]
    else
      Common_::KNOWN_UNKNOWN
    end
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # ==

  class Attributes < ::Module  # :[#013].

    # (subclass module because #here2)

    class << self
      alias_method :[], :new
      alias_method :call, :new
      undef_method :new
    end  # >>

    def initialize h
      @association_class = nil
      @_h = h
      @meta_associations_module = nil
      # (can't freeze because #here1)
    end

    # --

    # ~ (feature-island proof of concept..) (moved here at #history-B) (:#here2)

    def define_meta_association___ * x_a, & p
      Home_::MetaAssociation_via_Iambic___.new( self, x_a, & p ).execute
    end

    def touch_writable_association_class__  # for above
      if @association_class
        self._COVER_ME__
      else
        const_defined? :Association and self._COVER_ME__
        cls = ::Class.new Home_::CommonAssociation
        const_set :Association, cls
        @association_class = cls
      end
    end

    def touch_writable_meta_associations_module___  # same
      if @meta_associations_module
        self._COVER_ME__
      else
        const_defined? :MetaAssociations and self._COVER_ME__
        # because proof-of-concept, we don't stack atop the common one but we could
        mod = ::Module.new
        const_set :MetaAssociations, mod
        @meta_associations_module = mod
      end
    end

    # ~

    attr_writer(
      # ~ #cov2.12
      :association_class,
      :meta_associations_module,
    )

    # --

    def init ent, a, & p  # :[#008.8]: #borrow-coverage from [sy]

      normalize_by do |o|

        o.argument_array = a
        o.entity_as_ivar_store = ent
        o.will_result_in_entity_on_success_
        o.listener = p
      end
    end

    def init_via_argument_scanner ent, scn, & p  # #coverpoint1.3, [hu] 4x

      normalize_by do |o|

        o.argument_scanner = scn
        o.entity_as_ivar_store = ent
        o.will_result_in_entity_on_success_
        o.listener = p
      end
    end

    def normalize_entity ent, & p  # #coverpoint1.4

      normalize_by do |o|
        o.entity_as_ivar_store = ent
        o.listener = p
      end
    end

    def normalize_by
      Home_::Normalization.call_by do |o|
        yield o
        o.association_index = _index
      end
    end

    # --

    def define_methods cls
      _index.enhance_entity_class__ cls
    end

    def symbols * sym
      if sym.length.zero?
        @_h.keys
      else
        _index.lookup_particular__( * sym )
      end
    end

    def is_X meta_k  # might be nil
      _index.is_X__ meta_k
    end

    def to_defined_attribute_stream
      _index.to_native_association_stream
    end

    def attribute k
      _index.read_association_ k
    end

    def _index  # :#here1
      @___index ||= ___build_index
    end
    alias_method :association_index, :_index  # #here3, [ac]

    def ___build_index

      Home_::AssociationIndex_.new( @_h,
        ( @meta_associations_module || Home_::CommonAssociationMetaAssociations_::ClassicMetaAttributes ),
        ( @association_class || Home_::CommonAssociation ),
      )
    end

    def ASSOCIATION_VALUE_READER_FOR ent
      Home_::CommonValueStores::AssociationValueReader.new ent, self
    end

    # ==

    module Actor

      class << self

        def _call cls, * a
          via cls, a
        end
        alias_method :[], :_call
        alias_method :call, :_call
        remove_method :_call

        def via cls, a  # (transitional implementation..)

          if a.length.zero?

            cls.extend ModuleMethods__
            cls.include InstanceMethods
            cls.const_set :ATTRIBUTES, nil
            NIL_

          elsif 1 == a.length and a.first.respond_to? :each_pair

            cls.extend ModuleMethods__
            cls.include InstanceMethods
            attrs = Here_[ a.first ]
            cls.const_set :ATTRIBUTES, attrs
            attrs  # as covered

          else

            cls.const_set :ATTRIBUTES, FlatAttributes___.new( a )

            cls.extend Flat_Actor_MMs___
            cls.include Flat_Actor_IMs___
            NIL_
          end
        end
      end  # >>

      # ===

      module ModuleMethods__

        # ~ ways to call your actor (pursuant to [#bs-028.5] name conventions)

        def via * x_a, & x_p  # #[#bs-028] reserved method name.
          call_via_iambic x_a, & x_p
        end

        def call_via_iambic x_a, & x_p
          sess = via_iambic x_a, & x_p
          if sess
            sess.execute
          else
            sess
          end
        end

        def with * x_a, & x_p
          via_iambic x_a, & x_p
        end

        def via_iambic x_a, & x_p
          via_argument_scanner Scanner_[ x_a ], & x_p
        end

        def via_argument_scanner scn, & x_p
          New_via__[ :process_argument_scanner_fully, scn, self, & x_p ]
        end

        def via_argument_scanner_passively scn, & x_p
          New_via__[ :process_argument_scanner_passively, scn, self, & x_p ]
        end

        def scanner_via_array x_a
          Common_::Scanner.via_array x_a
        end
      end

      # ===

      New_via__ = -> m, scn, cls, & x_p do  # near [#026]: struct vs. actor: cold vs. hot

        sess = cls.send :new, & x_p  # actors reasonably expect the handler here [br]

        kp = sess.send m, scn, & x_p  # but this here is for all non-actors

        kp && sess
      end

      # ===

      module InstanceMethods

        def new_with * x_a, & x_p
          x_p and self._DESIGN_ME
          otr = dup
          kp = otr.send :process_iambic_fully, x_a
          if kp
            otr
          else
            self._COVER_ME
          end
        end

      private

        def process_iambic_fully x_a
          process_argument_scanner_fully scanner_via_array x_a
        end

        def scanner_via_array x_a
          Common_::Scanner.via_array x_a
        end

        def process_argument_scanner_fully scn, & p
          as_attributes_actor_parse_and_normalize scn do |o|
            o.listener = p
          end
        end

        def process_argument_scanner_passively scn, & p
          as_attributes_actor_parse_and_normalize scn do |o|
            o.will_parse_passively__
            o.listener = p
          end
        end

        def as_attributes_actor_parse_and_normalize scn

          instance_variable_set ARGUMENT_SCANNER_IVAR_, scn  # as we do

          ok = Home_::Normalization.call_by do |o|

            yield o

            __push_methods_reader_first_FI o

            _write_defined_associations_into_normalization_FI_ o

            o.entity_as_ivar_store = self  # entity not just ivar store because:

              # :#spot1-5 some association interpreters need to write directly
              # :#spot1-4 in error cases we inspect the entity lazily for handlers

            o.argument_scanner = scn
          end

          remove_instance_variable ARGUMENT_SCANNER_IVAR_  # (often the next method freezes)

          ok &&= as_attributes_actor_normalize

          ok
        end

        def as_attributes_actor_normalize
          KEEP_PARSING_  # #public-API: do nothing else here in this default form
        end

        def _write_defined_associations_into_normalization_FI_ n11n

          # it is a point of our #public-API that the client is free of any
          # obligation to define an `ATTRIBUTES` const (e.g [#co-007.1]).
          #
          # (if it wants to be explicit, the client can set such a const
          # to false-ish and it will have the same effect.)
          #
          # a client that (at writing) has no defined attributes can be seen
          # by simply running the [ts] quickie recursive runner.

          cls = self.class
          if cls.const_defined? :ATTRIBUTES, false
            ascs = cls.const_get :ATTRIBUTES
            if ascs
              _ascs_idx = ascs.association_index  # :#here3
            end
          end

          n11n.association_index = _ascs_idx  # whether or not an index is
            # present, setting this is necessary to help let the store
            # know when it is done being defined

          NIL
        end

        def __push_methods_reader_first_FI n11n

          # any client entity can define an association that is discovered
          # only lazily using the technique described at [#013]. (unlike in
          # [ac] we do not attempt to index such associations up front.)
          #
          # as such we must be prepared to accomodate every client in such
          # a manner, whether or not they employ this techique.
          #
          # push this soft reader first as an optimization because it's
          # used less frequently than traditionally defined attributes.

          meths = Home_::AssociationIndex_::Writer_method_reader[ self.class ]

          n11n.push_association_soft_reader_by__ do |k|  # exactly [#013]
            m = meths[ k ]
            m and Home_::AssociationIndex_::MethodBasedAssociation.new m
          end

          NIL
        end

        def gets_one  # #public-API #hook-in
          @_argument_scanner_.gets_one
        end

        def argument_scanner  # n.c
          @_argument_scanner_
        end

        def when_after_process_iambic_fully_stream_has_content scn  # :+#public-API

          _ev = Home_::Events::Extra.with :unrecognized_token, scn.head_as_is

          receive_extra_values_event _ev
        end

        def receive_extra_values_event ev  # :+#public-API (name) :+#hook-in
          raise ev.to_exception
        end
      end

      # ===

      module Flat_Actor_MMs___

        include ModuleMethods__

        def backwards_curry  # eek
          -> * x_a, & oes_p do
            Home_::CurriedActor_.backwards_curry__ self, x_a, & oes_p
          end
        end

        def curry_with * x_a, & oes_p
          Home_::CurriedActor_.curry__ self, x_a, & oes_p
        end

        def [] * a, & oes_p
          call_via_arglist a, & oes_p
        end

        def call * a, & oes_p
          call_via_arglist a, & oes_p
        end

        def call_via_arglist a, & x_p

          sess = new( & x_p )
          _ok = sess.process_arglist_fully a
          _ok && sess.execute
        end
      end

      # ===

      module Flat_Actor_IMs___  # NOW GO THIS AWAY

        include InstanceMethods

        def process_arglist_fully a

          # (for now we're keeping it very simple, but if for some reason
          # we wanted to use normal normalization etc, we would probably
          # make a functional scanner that qualifies each element..)

          bx = self.class::ATTRIBUTES.ivars_box_

          a.length.times do |d|
            instance_variable_set bx.at_offset( d ), a.fetch( d )
          end

          KEEP_PARSING_
        end

        def process_argument_scanner_passively scn
          ::Kernel._OKAY__this_is_in_notes__
        end

        def process_argument_scanner_fully scn
          super
        end

        def _write_defined_associations_into_normalization_FI_ n11n

          _this_thing = self.class.const_get :ATTRIBUTES, false  # #here4
          n11n.association_index = _this_thing
          NIL
        end
      end

      # ===

      class FlatAttributes___

        def initialize sym_a
          @__sym_a = sym_a
        end

        # ~ ( #here4 act as an argument index

        def association_hash_
          ivars_box_.h_
        end

        def diminishing_pool_prototype_
          ivars_box_.h_
        end

        def argument_value_parser_via_normalization_ n11n

          scn = n11n.argument_scanner
          ent = n11n.entity  # ##spot1-5

          -> ivar_as_asc do

            scn.advance_one  # #[#012.L.1] advance over the primary name

            _value = scn.gets_one  # there are no flags
            ent.instance_variable_set ivar_as_asc, _value
            KEEP_PARSING_
          end
        end

        def extroverted_association_normalizer_via_normalization_ n11n

          -> ivar_as_asc do
            $stderr.puts "COULD HAVE nilified or whined about missing required: #{ ivar_as_asc }"
            KEEP_PARSING_
          end
        end

        # ~ )

        def ivars_box_
          @___ivars_box ||= __ivars_box
        end

        def __ivars_box
          bx = Common_::Box.new
          remove_instance_variable( :@__sym_a ).each do |sym|
            bx.add sym, :"@#{ sym }"
          end
          bx
        end
      end

      # ===

      Autoloader_[ self ]
    end  # actor

    # --

    Autoloader_[ self ]
    Here_ = self
  end  # attributes

  # ==

  class CautiousAssociationIndex  # exactly [#002.E.2] "new lingua franca"

    def initialize p

      @_to_array = :__to_array_initially
      @_to_stream = :__to_stream_initially

      @_stream_by = p
    end

    def dereference_association_via_symbol__ sym
      a = association_array
      _d = a.index do |asc|
        sym == asc.name_symbol
      end
      a.fetch _d
    end

    # ~

    def association_array
      send @_to_array
    end

    def __to_array_initially
      @_array = _flush_stream.to_a.freeze
      @_to_stream = :__to_stream_via_array
      @_to_array = :__to_array_subsequently
      freeze
      @_array
    end

    def __to_array_subsequently
      @_array
    end

    # ~

    def to_native_association_stream
      send @_to_stream
    end

    def __to_stream_via_array
      Stream_[ @_array ]
    end

    def __to_stream_initially
      @_to_array = :_CANNOT_WITHOUT_ETC
      @_to_stream = :_ALREADY_EXECUTED_ONCE
      _flush_stream
    end

    def _flush_stream
      remove_instance_variable( :@_stream_by ).call
    end

    # ~

    def to_is_required_by
      -> asc do
        if asc.parameter_arity_is_known
          Is_required[ asc ]
        else
          TRUE  # contrary to spec. see comment
        end
      end
    end
  end

  # ==

  module AssociationValueProducerConsumerMethods_  # 2x

    # (something to share between assocation class and meta-association
    # classes. a bit of a #stowaway here. here b.c assocs always use this
    # node and it's otherwise light..)

    def init_association_value_producer_consumer_ivars_

      @_receive_interpreterer_AVPC = :__receive_interpreterer
      @_receive_producerer_AVPC = :__receive_producerer
      @_receive_consumerer_AVPC = :__receive_consumerer

      @_producer_by_AVPC = nil
      @_consumer_by_AVPC = nil
      @_interpreter_by_AVPC = nil

      @_entity_class_enhancer_procs_AVPC = nil
    end

    # -- ..

    def add_enhance_entity_class_proc__ p
      ( @_entity_class_enhancer_procs_AVPC ||= [] ).push p ; nil
    end

    # -- ..

    def argument_interpreter_by_ & p
      send @_receive_interpreterer_AVPC, p
    end

    def argument_value_producer_by_ & p
      send @_receive_producerer_AVPC, p
    end

    def argument_value_consumer_by_ & p
      send @_receive_consumerer_AVPC, p
    end

    def __receive_interpreterer p
      @_receive_interpreterer_AVPC = :_closed
      @_receive_producerer_AVPC = :_closed
      @_receive_consumerer_AVPC = :_closed
      @_interpreter_by_AVPC = p ; nil
    end

    def __receive_producerer p
      @_receive_interpreterer_AVPC = :_closed
      @_receive_producerer_AVPC = :_closed
      @_producer_by_AVPC = p ; nil
    end

    def __receive_consumerer p
      @_receive_interpreterer_AVPC = :_closed
      @_receive_consumerer_AVPC = :_closed
      @_consumer_by_AVPC = p ; nil
    end

    def close_association_value_producer_consumer_mutable_session_

      remove_instance_variable :@_receive_interpreterer_AVPC
      remove_instance_variable :@_receive_producerer_AVPC
      remove_instance_variable :@_receive_consumerer_AVPC

      interpreter_by = remove_instance_variable :@_interpreter_by_AVPC

      if interpreter_by
        remove_instance_variable :@_producer_by_AVPC
        remove_instance_variable :@_consumer_by_AVPC
        @__interpret_argument_AVPC = interpreter_by[ self ]
        @_flush_DSL_AVPC = :__flush_DSL_via_custom_interpreter_AVPC
      else
        r_p = remove_instance_variable :@_producer_by_AVPC
        w_p = remove_instance_variable :@_consumer_by_AVPC
        @produce_argument_value_by__ = r_p ? r_p[ self ] : Produce_value___
        @consume_argument_value_by__ = w_p ? w_p[ self ] : Consume_value___
        @_flush_DSL_AVPC = :__flush_DSL_commonly_AVPC
      end

      p_a = remove_instance_variable :@_entity_class_enhancer_procs_AVPC
      if p_a
        @__prepared_entity_class_enhancer_procs_AVPC = p_a.map do |p|
          p[ self ]  # eesh that timing
        end.freeze
      end

      NIL
    end

    # -- "read" (use)

    def enhance_this_entity_class_ ent_cls  # assume etc

      @__prepared_entity_class_enhancer_procs_AVPC.each do |p|
        p[ ent_cls ]
      end
      NIL
    end

    def as_association_interpret_ n11n, & p

      _dsl = Home_::Interpretation_::ArgumentValueInterpretation_DSL.new p, self, n11n
      flush_DSL_for_interpretation_ _dsl
    end

    def flush_DSL_for_interpretation_ dsl  # 3x in [fi]

      send @_flush_DSL_AVPC, dsl
    end

    def __flush_DSL_via_custom_interpreter_AVPC dsl  # result in kp

      dsl.calculate( & @__interpret_argument_AVPC )
    end

    def __flush_DSL_commonly_AVPC dsl  # result in kp

      dsl.as_DSL_flush_commonly_for_interpretation__
    end

    attr_reader(
      :produce_argument_value_by__,
      :consume_argument_value_by__,
    )
  end

  Produce_value___ = -> do
    # [#012.L.1] *DO* advance. (eager parsing)
    argument_scanner_.gets_one
  end

  Consume_value___ = -> x, _ do
    write_association_value_ x
  end

  # ==

  class SimplifiedName

    # like [#co-060] but only symbol & ivar (& upgrades to name function)
    # born as a base class for association but we use composition now instead

    def initialize k
      @cache_ = {}
      yield self
      @name_symbol = k
      freeze
    end

    def initialize_copy _
      @cache_ = @cache_.dup
    end

    def attr_writer_method_name  # #n.c [hu]
      _cached :___awmn
    end

    def ___awmn
      :"#{ @name_symbol }="
    end

    def as_ivar= x
      @cache_[ :_as_ivar ] = x
    end

    def as_ivar
      _cached :_as_ivar
    end

    def _as_ivar
      :"@#{ @name_symbol }"
    end

    def name= x
      @cache_[ :_name_function ] = x
    end

    def name  # for [#br-035] (wormhole). also covered here
      _cached :_name_function
    end

    def _name_function
      Common_::Name.via_variegated_symbol @name_symbol
    end

    def _cached m
      @cache_.fetch m do
        x = send m
        @cache_[ m ] = x
        x
      end
    end

    attr_reader(
      :name_symbol,
    )
  end

  class Argument_scanner_via_value  # :[#019] (2x similar)

    class << self

      def [] x
        new Common_::Known_Known[ x ]
      end

      def via_known_known kn  # [ac]
        new kn
      end

      private :new
    end  # >>

    def initialize kn
      @_done = false
      @_kn = kn
    end

    def gets_one
      x = head_as_is
      advance_one
      x
    end

    def head_as_is
      @_kn.value_x
    end

    def advance_one
      remove_instance_variable :@_kn
      @_done = true ; nil
    end

    def unparsed_exists
      ! @_done
    end

    def no_unparsed_exists
      @_done
    end
  end

  # ==

  class IvarBasedSimplifiedValidValueStore  # [ta]

    def initialize object
      @_object = object
    end

    def write_via_association x, asc
      @_object.instance_variable_set asc.as_ivar, x
      NIL
    end

    def read_softly_via_association asc
      if knows_value_for_association asc
        dereference_association asc
      end
    end

    def knows_value_for_association asc
      @_object.instance_variable_defined? asc.as_ivar
    end

    def dereference_association asc
      @_object.instance_variable_get asc.as_ivar
    end

    def simplified_write_ x, k  # necessary IFF :#spot1-3
      @_object.instance_variable_set :"@#{ k }", x ; nil
    end

    def simplified_read_ k
      ivar = :"@#{ k }"
      if @_object.instance_variable_defined? ivar
        @_object.instance_variable_get ivar
      end
    end
  end

  # ==

  # -- the external functions experiment (see [#010])

  # ~ description & name

  N_lines = -> d, expag, prp do  # #curry-friendly

    p = prp.description_proc
    if p
      if d
        N_lines_via_proc[ d, expag, p ]
      else
        expag.calculate [], & p
      end
    else
      NOTHING_
    end
  end

  N_lines_via_proc = -> d, expag, p do

    o = Home_.lib_.basic::String::N_Lines.session

    o.number_of_lines = d  # nil OK

    o.expression_agent = expag

    o.description_proc = p

    o.execute
  end

  Has_description = -> prp do
    prp.description_proc
  end

  # ~ normalization-related (including parameter arity derivatives)

  Has_default = -> prp do
    prp.default_proc
  end

  includes_zero = nil

  Is_effectively_optional = -> prp do
    if prp.default_proc
      true
    elsif prp.parameter_arity_is_known
      ! Is_required[ prp ]
    else
      false  # assume the old default [#002.4] of it being required
    end
  end

  Is_required = -> prp do

    # this is only a function of the `parameter_arity` (not the argument
    # arity). the normalizing agent must handle cases like lists and flags
    # itself..

    ! includes_zero.fetch prp.parameter_arity
  end

  # ~ argument arity derivations

  Takes_many_arguments = -> prp do
    if Takes_argument[ prp ]
      if Can_be_more_than_one[ prp.argument_arity ]
        true
      elsif prp.parameter_arity_is_known
        if Can_be_more_than_one[ prp.parameter_arity ]
          # (if you want to remove this expressive redundancy,
          # start from :[#008.5] (#borrow-coverage from [ze]))
          true  # hi.
        end
      else
        false  # assume the old parameter arity default of one [#002.4]
      end
    end
  end

  Argument_is_optional = -> prp do  # assume "takes argument"

    # an argument being optional is different than a parameter being optional.
    # avoid this nastiness if you have a choice! more at [#br]#self-wormhole-1

    includes_zero.fetch prp.argument_arity
  end

  Takes_argument = -> prp do
    Can_be_more_than_zero[ prp.argument_arity ]
  end

  # ~ support

  includes_zero = {
    one: false,
    one_or_more: false,
    zero: true,
    zero_or_one: true,
    zero_or_more: true,
  }

  Can_be_more_than_zero = {
    zero_or_one: true,
    one: true,
    zero_or_more: true,
    one_or_more: true,
  }

  Can_be_more_than_one = {
    zero_or_more: true,
    one_or_more: true,
  }

  # --

  module NO_LENGTH_ ; class << self
    def length
      0
    end
  end ; end

  # --

  Attr_writer_method_name_ = -> name_symbol do
    :"#{ name_symbol }="
  end

  Scanner_ = -> a do  # #todo with [sa] etc
    Common_::Scanner.via_array a
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  # --

  ArgumentError = ::Class.new ::ArgumentError

  MissingRequiredAttributes = ::Class.new ArgumentError

  StateError_ = ::Class.new ::RuntimeError

  # --

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Human = sidesys[ :Human ]
    Parse = sidesys[ :Parse ]
    Plugin = sidesys[ :Plugin ]
  end

  ACHIEVED_ = true
  ARGUMENT_SCANNER_IVAR_ = :@_argument_scanner_
  CLI = nil  # for host
  CONST_SEP_ = Common_::CONST_SEPARATOR
  EMPTY_A_ = []
  EMPTY_S_ = ""
  Home_ = self
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  Lazy_ = Common_::Lazy
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NIL_ = nil
  NILADIC_TRUTH_ = -> { TRUE }
  NOTHING_ = nil
  SPACE_ = ' '
  STOP_PARSING_ = false
  UNABLE_ = false
  USE_WHATEVER_IS_DEFAULT_ = nil

  def self.describe_into_under y, _
    y << "for modeling { arguments | attributes | parameters | properties }"
  end
end
# :#history-B - as referenced
# #history - backwards_curry moved
