module Skylab::Fields

  class Parameter  # *read* [#009]

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

    module Definer_Module_Methods  # :+#public-API ([tm])

      attr_reader :parameters_p

      def meta_param sym, * x_a, & x_p
        parameters.__touch_meta_parameter( sym )._accept_iambic x_a, & x_p
      end

      def param sym, * x_a, & x_p
        parameters._touch_parameter( sym )._accept_iambic x_a, & x_p
      end

      attr_reader :parameters
      alias_method :any_parameters, :parameters

      def parameters
        @parameters ||= __build_parameters
      end

      def __build_parameters

        col = Models__Collection.new self
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

        mods.reverse.each do | mod |
          col._receive_parameter_collection_to_merge mod.parameters
        end

        if parameters_p
          @parameters = col # prevent inf. recursion, the below call may need this
          instance_exec(&@parameters_p)
          @parameters_p = nil
        end

        if const_defined? :PARAMS, false

          # this is an ugly little #experimental shorthand

          self::PARAMS.each do | sym |
            col._touch_parameter( name )._be :accessor, :required
          end
        end

        col
      end
    end

    # ~ conveninence maker for hash-based parameters structure [hl]

    def Definer.new & edit_p
      cls = ::Class.new Dynamic_Definer___
      cls.class_exec( & edit_p )
      cls
    end

    # ~ instance method modules

    CONST__ = :Parameter
    Here_ = self

    module Hash_Adapter_Methods___

      const_set CONST__, Here_

    end

    module Struct_Adapter_Methods  # :+#public-API [tm]

      const_set CONST__, Here_

    protected
      def fetch k
        self[ k ]
      end
    end

    module Ivars_Adapter_Methods  # :+#public-API [tm]

      const_set CONST__, Here_

    protected  # :+#protected-not-private

      def fetch k, & else_p

        ivar = :"@#{ k }"

        if else_p
          if instance_variable_defined? ivar
            instance_variable_get ivar
          else
            else_p[]
          end
        else
          instance_variable_get ivar
        end
      end

      def []= k, x
        instance_variable_set :"@#{ k }", x
      end
    end

    class Dynamic_Definer___ < ::Hash

      const_set CONST__, Here_

      extend Definer_Module_Methods

      def initialize
        yield self
      end
    end

    # ~ internal support (models)

    class Models__Collection  # was "set"

      def initialize entity_model
        @_bx = Callback_::Box.new
        @_entity_model = entity_model
      end

      # ~ readers

      def fetch k, & p
        @_bx.fetch k, & p
      end

      def to_value_stream & x_p
        @_bx.to_value_stream( & x_p )
      end

      # ~ writers

      def _touch_parameter sym
        @_bx.touch sym do
          ( @_entity_model.const_get CONST__ ).new @_entity_model, sym
        end
      end

      def _receive_parameter_collection_to_merge col

        st = col.to_value_stream
        begin
          prp = st.gets
          prp or break

          prp_ = _touch_parameter( prp.name_symbol )
          st_ = prp.__to_any_polymorphic_upstream
          if st_
            prp_._accept_polymorphic_upstream st_
          end
          redo
        end while nil
        NIL_
      end

      def __touch_meta_parameter sym

        _mp = __meta_collection._touch_parameter sym
        _mp
      end

    private

      def __meta_collection
        @___mc ||= __build_meta_collection
      end

      def __build_meta_collection  # [#.A]

        # always makes a dedicated class in the entity model for now

        entity_model = @_entity_model

        if entity_model.const_defined? CONST__, false
          self._COVER_ME
          cls = entity_model.const_get CONST__
        else
          cls = ::Class.new entity_model.const_get CONST__
          entity_model.const_set CONST__, cls
        end

        cls.parameters
      end
    end

    # ~ as class

    attr_reader(
      :name_symbol,
    )

    def initialize host_module, sym  # [#.B]

      @entity_model = host_module
      @name_symbol = sym
      @normal_iambic = []
    end

    def _accept_parameter_to_merge prp

      _accept_polymorphic_upstream prp.__to_polymorphic_upstream
    end

    def __to_any_polymorphic_upstream

      Callback_::Polymorphic_Stream.via_array @normal_iambic
    end

    def _accept_iambic x_a, & x_p

      _accept_polymorphic_upstream(
        Callback_::Polymorphic_Stream.via_array( x_a ), & x_p )
    end

    def _accept_polymorphic_upstream st, & edit_p

      @polymorphic_upstream_ = st

      while st.unparsed_exists
        send :"when__#{ st.gets_one }__"
      end

      if edit_p
        instance_exec( & edit_p )
      end

      remove_instance_variable :@polymorphic_upstream_
      NIL_
    end

    # ~ modifiers [#.C]

    ## ~~ pre support

    def when__monadic__

      send :"when__#{ @polymorphic_upstream_.gets_one }__"
    end

    ## ~~ boolean: reader_looks_like_this?, writer_looks_like_this! (legacy)

    def when__boolean__

      @normal_iambic.push :monadic, :boolean

      mod = @entity_model
      sym = @name_symbol

      st = @polymorphic_upstream_
      if st.unparsed_exists &&
          :negated_boolean_reader_method_name == st.current_token

        st.advance_one
        neg = st.gets_one
      else
        neg = :"not_#{ sym }"
      end

      mod.module_exec do

        define_method :"#{ sym }?" do

          fetch sym do
            NIL_  # (was once false)
          end
        end

        define_method :"#{ neg }?" do

          ! fetch sym do
            false
          end
        end

        define_method :"#{ sym }!" do
          self[ sym ] = true
          NIL_
        end

        define_method :"#{ neg }!" do
          self[ sym ] = false
          NIL_
        end

        define_method :"when__#{ sym }__" do
          self[ sym ] = true
          KEEP_PARSING_
        end
      end
      KEEP_PARSING_
    end

    ## ~~ enum: validation on write. assumes selective event handler.

    def when__enum__

      enum_list = @polymorphic_upstream_.gets_one
      enum_box = nil  # built late
      init_box = -> do
        enum_box = Callback_::Box.new
        enum_list.each do | x |
          enum_box.add x, true
        end
        NIL_
      end

      me = self
      sym = @name_symbol
      wm = writer_method_name or raise ::ArgumentError, __say_enum

      is_writer = EQUALS_BYTE__ == wm.id2name.getbyte( -1 )

      @entity_model.module_exec do

        if is_writer

          downstream_method = :"accept__#{ sym }__after_enum"

          alias_method downstream_method, wm

          accept_bad_enum = :"accept_bad_enum_value_for__#{ sym }__"

          define_method wm do | x |

            enum_box || init_box[]
            if enum_box.has_name x
              send downstream_method, x
            else
              send accept_bad_enum, x, enum_box, me
            end
            x
          end

          define_method accept_bad_enum, ACCEPT_BAD_ENUM_VALUE__
        else

          downstream_method = :"receive__#{ sym }__after_enum"

          alias_method downstream_method, wm

          receive_bad_enum = :"receive_bad_enum_value_for__#{ sym }__"

          define_method wm do | x |

            enum_box || init_box[]
            if enum_box.has_name x
              send downstream_method, x
            else
              send receive_bad_enum, x, enum_box, me
            end
          end

          define_method receive_bad_enum, RECEIVE_BAD_ENUM_VALUE___
        end
      end
      KEEP_PARSING_
    end

    attr_reader :writer_method_name

    def __say_enum
      "`enum` modifier must come after #{
        }a modification that establishes a writer method"
    end

    build_extra_value_event_proc = -> do

      Home_::MetaMetaFields::Enum::Build_extra_value_event
    end

    EQUALS_BYTE__ = '='.getbyte 0

    RECEIVE_BAD_ENUM_VALUE___ = -> x, bx, prp do

      @on_event_selectively.call :error, :invalid_property_value do

        build_extra_value_event_proc[][ x, bx.get_names, prp.name ]
      end
    end

    ACCEPT_BAD_ENUM_VALUE__ = -> x, bx, prp do

      @on_event_selectively.call :error, :invalid_property_value do

        build_extra_value_event_proc[][ x, bx.get_names, prp.name ]
      end
      NIL_
    end

    ## ~~ DSL (atom | list): the writer does not end in a '='

    def when__DSL__
      send :"when_DSL__#{ @polymorphic_upstream_.gets_one }__"
    end

    attr_reader :is_list

    def when_DSL__list__

      @normal_iambic.push :DSL, :list
      do_reader = _maybe_do_DSL_reader
      sym = @name_symbol
      @writer_method_name = sym
      @is_list = true

      @entity_model.module_exec do

        define_method sym do | x |

          a = fetch sym do end

          if ! a
            a = []
            self[ sym ] = a
          end

          a.push x

          NIL_
        end

        if do_reader

          define_method :"#{ sym }_array" do

            fetch sym do end
          end
        end
      end

      KEEP_PARSING_
    end

    def when_DSL__atom__

      @normal_iambic.push :DSL, :atom
      do_reader = _maybe_do_DSL_reader
      sym = @name_symbol
      @writer_method_name = sym

      @entity_model.module_exec do

        define_method sym do | x |
          self[ sym ] = x
          NIL_
        end

        if do_reader

          define_method :"#{ sym }_x" do

            fetch sym do end
          end
        end
      end

      KEEP_PARSING_
    end

    def _maybe_do_DSL_reader

      if @polymorphic_upstream_.unparsed_exists &&
          :reader == @polymorphic_upstream_.current_token

        @polymorphic_upstream_.advance_one

        @normal_iambic.push :reader

        true
      end
    end

    ## ~~ default: needs special processing by client

    attr_reader :has_default
    alias_method :has_default?, :has_default  # #todo

    def default_value  # the one reader
      @_default_proc.call
    end

    def when__default__  # when set by iambic
      x = @polymorphic_upstream_.gets_one
      _accept_default_by do
        x
      end
      KEEP_PARSING_
    end

    def default & p  # when set by definition block (only way to write proc)
      _accept_default_by( & p )
    end

    def _accept_default_by & p
      @normal_iambic.push :default_proc, p
      @has_default = true
      @_default_proc = p
      NIL_
    end

    ## ~~ hook: an accessor sugared for being a proc

    def when__hook__

      if @polymorphic_upstream_.unparsed_exists &&
          :reader == @polymorphic_upstream_.current_token

        @polymorphic_upstream_.advance_one
        do_reader = true
      end

      sym = @name_symbol

      md = HOOK_METHOD_NAME_RX___.match sym
      if md
        stem = md[ 0 ]
        read_write_key = stem
        on_like_method_name = sym
        if do_reader
          reader_method_name = :"handle_#{ stem }"
        end
      else
        read_write_key = sym
        on_like_method_name = :"on_#{ sym }"
        if do_reader
          reader_method_name = :"handle_#{ sym }"
        end
      end

      handle_like_method_name = :"handle_#{ read_write_key }"
      normal_writer_method_name = :"#{ handle_like_method_name }="

      @entity_model.module_exec do

        if reader_method_name

          define_method reader_method_name do

            fetch read_write_key do end
          end
        end

        define_method on_like_method_name do | & p |
          p or raise ::ArgumentError, '[past-proofing]'  # past-proof
          self[ read_write_key ] = p
        end

        define_method normal_writer_method_name do | p |
          self[ read_write_key ] = p
        end
      end
      KEEP_PARSING_
    end

    HOOK_METHOD_NAME_RX___ = /(?<=\Aon_).+/

    ## ~~ builder: a reader that initializes with a proc (named thru reader)

    def when__builder__

      builder_proc_reader_name = @polymorphic_upstream_.gets_one
      sym = @name_symbol

      @entity_model.module_exec do

        define_method sym do

          yes = nil
          x = fetch sym do
            yes = true
          end
          if yes
            x = send( builder_proc_reader_name ).call
            self[ sym ] = x
          end
          x
        end
      end
      KEEP_PARSING_
    end

    ## ~~ accesssor: like `attr_accessor`

    def when__accessor__

      when__reader__
      when__writer__
    end

    ## ~~ reader: like `attr_reader`

    def when__reader__

      @normal_iambic.push :reader
      sym = @name_symbol

      @entity_model.module_exec do

        define_method sym do
          fetch sym do end
        end
      end

      KEEP_PARSING_
    end

    ## ~~ writer: like `attr_writer`

    def when__writer__

      @normal_iambic.push :writer

      sym = @name_symbol
      wm = :"#{ sym }="
      @writer_method_name = wm

      @entity_model.module_exec do

        define_method wm do | x |
          self[ sym ] = x
        end
      end

      KEEP_PARSING_
    end

    # ~ constants

    KEEP_PARSING_ = true

    # ~ DOGFOOD [#.E] - the below are implemented with the the above facilities

    Definer[ self ]

    ## ~~ the `desc` meta-property

    param :desc, :DSL, :list, :reader  # (really only here b.c is covered)

    # ~ all-around reflection & support

    def name
      @___nm ||= Callback_::Name.via_variegated_symbol @name_symbol
    end

  end
end

# :+#tombstone: [#009.D] 'Actual_Parameters_Ivar_Instance_Methods' un-abstacted
