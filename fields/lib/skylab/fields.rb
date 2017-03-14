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

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # ==

  class Attributes < ::Module  # :[#013]

    class << self

      alias_method :[], :new
      alias_method :call, :new
      undef_method :new

      def struct_class
        const_get :Struct, false  # because there is a toplevel such name, and etc
      end
    end  # >>

    def initialize h
      @attribute_class = nil
      @_h = h
      @meta_attributes = nil
      # (can't freeze because #here-1)
    end

    # --

    def define_meta_attribute * x_a, & x_p
      Here_::DSL.new( self, x_a, & x_p ).execute
    end

    attr_writer(
      :attribute_class,
      :meta_attributes,
    )

    def attribute_class__
      @attribute_class
    end

    def meta_attributes__
      @meta_attributes
    end

    # --

    def init ent, a, & p  # :[#008.8]: #borrow-coverage from [sy]

      _normalize_by do |o|

        o.argument_array = a
        o.entity = ent
        o.will_result_in_entity_on_success_
        o.listener = p
      end
    end

    def init_via_argument_scanner ent, scn, & p  # #coverpoint1.3, [hu] 4x

      _normalize_by do |o|

        o.argument_scanner = scn
        o.entity = ent
        o.will_result_in_entity_on_success_
        o.listener = p
      end
    end

    def normalize_entity ent, & p  # #coverpoint1.4

      _normalize_by do |o|
        o.entity = ent
        o.listener = p
      end
    end

    def _normalize_by
      Here_::Normalization.call_by do |o|
        yield o
        o.association_index = _index
      end
    end

    def begin_normalization & x_p
      self._GONE__see_me__
    end

    # --

    def define_methods mod
      _index.define_methods__ mod
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

    def _index  # #here-1
      @___index ||= ___build_index
    end
    alias_method :association_index, :_index  # here, [ac]

    def ___build_index
      Here_::AssociationIndex_.new( @_h,
        ( @meta_attributes || Here_::MetaAttributes ),
        ( @attribute_class || Here_::DefinedAttribute ),
      )
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

            cls.const_set :ATTRIBUTES, Flat_Attributes___.new( a )

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

          _st = Common_::Scanner.via_array x_a
          New_via__[ :process_argument_scanner_fully, _st, self, & x_p ]
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

      New_via__ = -> m, scn, cls, & x_p do  # near #open [#026]: struct vs. actor: cold vs. hot

        sess = cls.send :new, & x_p  # actors reasonably expect the handler here [br]

        kp = sess.send m, scn, & x_p  # but this here is for all non-actors

        if kp
          sess
        else
          kp
        end
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

        def process_argument_scanner_fully scn, & x_p
          kp = process_argument_scanner_passively scn, & x_p
          if kp
            if scn.no_unparsed_exists
              kp
            elsif x_p
              self._K
            else
              when_after_process_iambic_fully_stream_has_content scn
            end
          else
            kp
          end
        end

        def process_argument_scanner_passively scn, & p

          cls = self.class
          if cls.const_defined? :ATTRIBUTES, false
            ascs = cls.const_get :ATTRIBUTES
            if ascs
              _ascs_idx = ascs.association_index
            end
          end

          # not all entities that employ the subject i.m module define
          # an `ATTRIBUTES` const. ([#co-007.1] is one example.)

          # entities can say they are an attributes actor but not
          # define an associations. (this is covered by running quickie)

          meths = argument_parsing_writer_method_name_passive_lookup_proc
          _lookup_association_softly = -> k do
            m = meths[ k ]
            m and Attributes::AssociationIndex_::MethodBasedAssociation.new m
          end

          instance_variable_set ARGUMENT_SCANNER_IVAR_, scn  # as we do

          # (this call is used all over)

          x = Here_::Normalization.call_by do |o|
            o.argument_scanner = scn
            o.push_association_soft_reader_by__( & _lookup_association_softly )
            o.association_index = _ascs_idx
            o.entity = self  # for #spot-1-5, some association interpreters need to write directly
            o.will_parse_passively__
            o.listener = p
          end

          remove_instance_variable ARGUMENT_SCANNER_IVAR_

          x  # entity or KEEP_PARSING_ or UNABLE_
        end

        def gets_one  # #public-API #hook-in
          @_argument_scanner_.gets_one
        end

        def argument_scanner  # n.c
          @_argument_scanner_
        end

        def argument_parsing_writer_method_name_passive_lookup_proc  # #public-API #hook-in 1x, 
          Here_::AssociationIndex_::Writer_method_reader[ self.class ]
        end

        def when_after_process_iambic_fully_stream_has_content stream  # :+#public-API

          _ev = Home_::Events::Extra.with :unrecognized_token, stream.head_as_is

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
            Actor::Curried.backwards_curry__ self, x_a, & oes_p
          end
        end

        def curry_with * x_a, & oes_p
          Actor::Curried.curry__ self, x_a, & oes_p
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

      module Flat_Actor_IMs___

        include InstanceMethods

        def process_argument_scanner_passively scn

          bx = self.class::ATTRIBUTES.ivars_box_

          until scn.no_unparsed_exists
            ivar = bx[ scn.head_as_is ]
            ivar or break
            scn.advance_one
            instance_variable_set ivar, scn.gets_one
          end

          KEEP_PARSING_  # we never fail softly
        end

        def process_arglist_fully a

          bx = self.class::ATTRIBUTES.ivars_box_

          a.length.times do |d|
            instance_variable_set bx.at_offset( d ), a.fetch( d )
          end

          KEEP_PARSING_
        end
      end

      # ===

      class Flat_Attributes___

        def initialize sym_a
          @_do = true
          @_sym_a = sym_a
        end

        def ivars_box_
          if @_do
            _parse
          end
          @__ivars_box
        end

        def _parse
          @_do = false
          bx = Common_::Box.new
          remove_instance_variable( :@_sym_a ).each do |sym|
            bx.add sym, :"@#{ sym }"
          end
          @__ivars_box = bx
          NIL_
        end
      end

      # ===

      Autoloader_[ self ]
    end  # actor

    # --

    Classic_writer_method_ = -> name_symbol do
      :"#{ name_symbol }="
    end

    # --

    Autoloader_[ self ]

    ARGUMENT_SCANNER_IVAR_ = :@_argument_scanner_
    Here_ = self
  end  # attributes

  # ==

  class CautiousAssociationIndex  # exactly [#002.D] "new lingua franca"

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

  # ~

  class SimplifiedName

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

    def simplified_write_ x, k  # necessary IFF :#here-7
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

  # (HERE)

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
  NILADIC_TRUTH_ = -> do
    true
  end
  NOTHING_ = nil
  SPACE_ = ' '
  STOP_PARSING_ = false
  UNABLE_ = false
  USE_WHATEVER_IS_DEFAULT_ = nil

  def self.describe_into_under y, _
    y << "for modeling { arguments | attributes | parameters | properties }"
  end
end
# #history - backwards_curry moved
