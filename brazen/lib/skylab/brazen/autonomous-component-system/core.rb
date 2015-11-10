module Skylab::Brazen

  module Autonomous_Component_System  # see [#089]

    class << self

      def create x_a, acs, & x_p  # :t2.

        o = _Mutation_Session.new( & x_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :create
        o.execute
      end

      def edit x_a, acs, & x_p  # :t3.

        o = _Mutation_Session.new( & x_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :edit
        o.execute
      end

      def interpret arg_st, acs, & x_p  # :+t6

        o = _Mutation_Session.new( & x_p )
        o.arg_st = arg_st
        o.ACS = acs
        o.macro_operation_method_name = :interpret
        o.execute
      end

      def component_already_added cmp, asc, acs, & oes_p

        oes_p.call :error, :component_already_added do

          event( :Component_Already_Added ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
            :ok, nil,  # overwrite so error becomes info
          )
        end
        UNABLE_  # important
      end

      def component_not_found cmp, asc, acs, & oes_p

        oes_p.call :error, :component_not_found do

          Home_.event( :Component_Not_Found ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
          )
        end
        UNABLE_  # important
      end

      def component_removed cmp, asc, acs, & oes_p

        oes_p.call :info, :component_removed do

          event( :Component_Removed ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
          )
        end
        ACHIEVED_
      end

      def event sym
        Home_::Events_.const_get sym, false
      end

      def _Mutation_Session
        ACS_::Mutation
      end
    end  # >>

    Component_Association = ::Class.new

    # how this unit is structured is the subject of the [#bs-039] case study

    method_name_for = -> sym do
      :"__#{ sym }__component_association"
    end

    Component_Association::Read = -> sym, acs, & else_p do

      m = method_name_for[ sym ]

      send = -> do
        ca = nil
        p = -> x do
          ca = Component_Association._begin_definition
          p = -> x_a do
            ca.send :"__accept__#{ x_a.first }__meta_component", * x_a[ 1..-1 ]
            NIL_
          end
          p[ x ]
        end

        cm = acs.send m do | * x_a |  # :t4.
          p[ x_a ]
        end

        if ca
          if cm
            ca._finish_definition_via cm, sym
          else
            self._DESIGN_ME_cover_me_compnoent_assoc_method_had_no_model
          end
        elsif cm
          Component_Association.
            _begin_definition.
              _finish_definition_via cm, sym
        else
          self._DESIGN_ME_cover_me__totally_empty_component_assoc
        end
      end

      if else_p
        if acs.respond_to? m
          send[]
        else
          else_p[]
        end
      else
        send[]
      end
    end

    class Component_Association

      # different concerns will construct these subject objects on demand
      # on-the-fly. for now internally we provide no way of memoizing them,
      # in contrast to [#001] properties which we took pains to freeze etc.
      # :[#089]:WISH-1: times when it feels wasteful to etc

      class << self

        def reader_for acs
          if acs.respond_to? CUSTOM_LOOKUP_METHOD__
            Dynamic_Reader___.for acs
          else
            Reader.for acs
          end
        end

        def via_symbol_and_ACS sym, acs
          if acs.respond_to? CUSTOM_LOOKUP_METHOD__
            acs.send CUSTOM_LOOKUP_METHOD__, sym
          else
            Read[ sym, acs ]
          end
        end

        def via_name_and_model nf, mdl

          _begin_definition._init_via nf, mdl
        end

        alias_method :_begin_definition, :new
        private :new
      end  # >>

      def initialize
        @_name_mutation = nil
        @_operations = nil
      end

      def _finish_definition_via cm, sym

        nf = Callback_::Name.via_variegated_symbol sym

        if @_name_mutation
          @_name_mutation[ nf ]  # *mutates*
        end

        _init_via nf, cm
      end

      def _init_via nf, mdl

        remove_instance_variable :@_name_mutation
        @component_model = mdl
        @name = nf
        self
      end

      # ~

      def to_linked_list_node_in_front_of name
        dup.___init_as_linked_list_node_in_front_of name
      end

      def ___init_as_linked_list_node_in_front_of x
        @next = x ; self
      end

      attr_reader :next

      # ~

      def description_under _expag
        @name.as_human
      end

      def __accept__can__meta_component * i_a  # :t8.

        bx = Callback_::Box.new
        i_a.each do | sym |
          bx.add sym, :declared
        end
        @_operations = bx
        NIL_
      end

      def __accept__intent__meta_component sym  # see [#083]:INTERP-B
        @intent = sym
        NIL_
      end

      attr_reader :intent

      def __accept__stored_in_ivar__meta_component ivar

        p = @_name_mutation
        @_name_mutation = -> nm do
          nm.as_ivar = ivar
          if p
            p[ nm ]
          end
          NIL_
        end
        NIL_
      end

      def any_delivery_mode_for sym

        if @_operations
          if @_operations[ sym ]
            mode = :association
          end
        end
        if mode
          mode
        elsif __model_has_operation sym
          :model
        end
      end

      def model_has_association sym
        @component_model.method_defined? :"__#{ sym }__component_association"
      end

      def __model_has_operation sym
        @component_model.method_defined? :"__#{ sym }__component_operation"
      end

      def has_operations
        ! @_operations.nil?
      end

      def operation_symbols

        bx = @_operations
        if bx
          bx.get_names
        else
          EMPTY_A_
        end
      end

      def name_symbol
        @name.as_variegated_symbol
      end

      attr_reader(
        :component_model,
        :name,
      )

      def category
        :association
      end

      def sub_category
        :common
      end

      class Reader

        class << self
          alias_method :for, :new
          private :new
        end  # >>

        def initialize acs
          @_ACS = acs
        end

        def [] sym
          Read[ sym, @_ACS ]
        end

        def fetch sym, & p
          Read[ sym, @_ACS, & p ]
        end
      end

      class Dynamic_Reader___ < Reader

        def [] sym
          @_ACS.send CUSTOM_LOOKUP_METHOD__, sym
        end

        def fetch sym, & p
          self._K
        end
      end

      CUSTOM_LOOKUP_METHOD__ = :lookup_component_association
    end

    module Reflection

      Model_is_compound = -> mdl do

        if mdl.respond_to? :method_defined?

          if mdl.method_defined? :to_component_symbol_stream
            true
          else
            ! ACS_::Reflection_::Method_index_of_class[ mdl ].association_symbols.nil?
          end
        end
      end
    end

    ACS_ = self
    Autoloader_[ Modalities = ::Module.new ]

    Value_Wrapper = -> x do
      Callback_::Known_Known[ x ]
    end
  end
end
