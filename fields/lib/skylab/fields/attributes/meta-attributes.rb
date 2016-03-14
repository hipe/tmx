module Skylab::Fields

  class Attributes

    class MetaAttributes < ::BasicObject  # 1x (this lib only). [#009]..

      def initialize build
        @_ = build
      end

      # -- the default meta-attributes in alphabetical order.

      def boolean  # for ancient DSL-controller. see also `flag`

        Home_::MetaAttributes::Boolean::Parse[ @_ ]
      end

      def component  # #experimental:
        # avoid dependency on [ac] for now. this is a microscopic ersatz of
        # it, to let the work form its own upgrade path..

        ca = @_.current_attribute

        # ca.is_defined_component = true  # #todo-soon

        ca.read_by do

          _m = :"__#{ formal_attribute.name_symbol }__component_association"
          _c = session.send _m  # no yield for now - if you need it, use [ac]
          _c.interpret_component argument_stream, formal_attribute
        end
      end

      def custom_interpreter_method

        # created to facilitate custom aliases [hu].
        # also bolsters readability for hybrid actors.

        ca = @_.current_attribute

        # ca.is_defined_component = true  # #todo-soon

        ca.read_and_write_by do

          _m = Classic_writer_method_[ formal_attribute.name_symbol ]

          sess = session

          if ! sess.instance_variable_defined? ARG_STREAM_IVAR_
            sess.instance_variable_set ARG_STREAM_IVAR_, argument_stream
            did = true
          end

          x = sess.send _m

          if did
            sess.remove_instance_variable ARG_STREAM_IVAR_
          end

          if ACHIEVED_ == x
            KEEP_PARSING_
          else
            raise ::ArgumentError, Say_expected_achieved___[ x ]
          end
        end
      end

      Say_expected_achieved___ = -> x do
        "expected #{ ACHIEVED_ } had #{ Home_.lib_.basic::String.via_mixed x }"
      end

      def default

        x = @_.sexp_stream_for_current_attribute.gets_one
        if x.nil?
          self._COVER_ME_dont_use_nil_use_optional
        end

        @_.current_attribute.be_defaultant_by_value__ x

        @_.add_to_static_index_ :effectively_defaultants ; nil
      end

      def enum
        Home_::MetaAttributes::Enum::Parse[ @_ ]
      end

      def flag
        @_.current_attribute.read_by do
          true
        end
      end

      def flag_of

        sym = @_.sexp_stream_for_current_attribute.gets_one
        ca = @_.current_attribute

        ca.read_by do
          true
        end

        ca.write_by do |x|

          # "flag of" must have the *full* pipeline of the referrant -
          # read *and* write.

          atr = index.lookup_attribute_ sym
          _mutate_for_redirect x, atr
          atr.read_and_write_ self  # result is kp
        end
      end

      def hook

        @_.add_methods_definer_by_ do |atr|

          ivar = atr.as_ivar ; k = atr.name_symbol

          -> mod do

            mod.module_exec do

              define_method :"on__#{ k }__" do | & p |
                instance_variable_set ivar, p ; nil
              end

              define_method :"receive__#{ k }__" do | * a, & p |
                instance_variable_get( ivar )[ * a, & p ]
                NOTHING_  # discourage bad design
              end
            end
          end
        end
      end

      def ivar
        @_.current_attribute.as_ivar = @_.sexp_stream_for_current_attribute.gets_one
      end

      def known_known

        @_.current_attribute.read_by do
          Callback_::Known_Known[ argument_stream.gets_one ]
        end
      end

      def list

        @_.add_methods_definer_by_ do |atr|

          -> mod do
            mod.send :define_method, atr.name_symbol do |x|
              ivar = atr.as_ivar
              if instance_variable_defined? ivar
                a = instance_variable_get ivar
              end
              if a
                a.push x
              else
                instance_variable_set ivar, [ x ]
              end
              NIL_
            end
          end
        end
      end

      def optional

        @_.current_attribute.be_optional__
        @_.add_to_static_index_ :effectively_defaultants ; nil
      end

      def singular_of

        sym = @_.sexp_stream_for_current_attribute.gets_one

        ca = @_.current_attribute

        ca.read_by do
          [ argument_stream.gets_one ]
        end

        ca.write_by do |x|

          atr = index.lookup_attribute_ sym
          _mutate_for_redirect x, atr
          atr.read_and_write_ self  # result is kp
        end
      end

      if false  # to #here

      # <-

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

      @_polymorphic_upstream_ = st

      while st.unparsed_exists
        send :"when__#{ st.gets_one }__"
      end

      if edit_p
        instance_exec( & edit_p )
      end

      remove_instance_variable :@_polymorphic_upstream_
      NIL_
    end

    # ~ modifiers [#.C]

    ## ~~ pre support

    def when__monadic__

      send :"when__#{ @_polymorphic_upstream_.gets_one }__"
    end

    ## ~~ DSL (atom | list): the writer does not end in a '='

    def when__DSL__
      send :"when_DSL__#{ @_polymorphic_upstream_.gets_one }__"
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

      st = @_polymorphic_upstream_

      if st.unparsed_exists && :reader == st.current_token
        st.advance_one
        @normal_iambic.push :reader
        true
      end
    end

    ## ~~ builder: a reader that initializes with a proc (named thru reader)

    def when__builder__

      builder_proc_reader_name = @_polymorphic_upstream_.gets_one
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

    # ~ DOGFOOD [#.E] - the below are implemented with the the above facilities

    Definer[ self ]

    ## ~~ the `desc` meta-property

    param :desc, :DSL, :list, :reader  # (really only here b.c is covered)

    # ~ all-around reflection & support

    def name
      @___nm ||= Callback_::Name.via_variegated_symbol @name_symbol
    end
  # ->
      end  # :#here
    end  # meta-attributes
  end  # attributes
end  # fields

# :+#tombstone: [#009.D] 'Actual_Parameters_Ivar_Instance_Methods' un-abstacted
# #tombstone: we broke out ANCIENT meta-params DSL at #spot-3
