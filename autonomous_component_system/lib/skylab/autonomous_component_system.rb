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

    Component_Association::Method_based_reader_for___ = -> ca_class, acs do

      send = -> m, sym do

        ca = nil

        p = -> x do
          ca = ca_class._begin_definition
          p = -> x_a do
            ca.send :"accept__#{ x_a.first }__meta_component", * x_a[ 1..-1 ]
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
          ca_class._begin_definition._finish_definition_via cm, sym
        else
          self._DESIGN_ME_cover_me__totally_empty_component_assoc
        end
      end

      -> sym, & else_p do

        m = method_name_for[ sym ]

        if else_p
          if acs.respond_to? m
            send[ m, sym ]
          else
            else_p[]
          end
        else
          send[ m, sym ]
        end
      end
    end

    COMPOUND_CONSTRUCTOR_METHOD_ = :interpret_compound_component

    class Component_Association

      # assume that the ACS assumes that these structures are produced
      # lazily, on-the-fly, and are not memoized to be used beyond the
      # "moment": they are #dt3 dynamic and should not be #dt4 cached.

      class << self

        def reader_for acs

          if acs.respond_to? METHOD__
            acs.send METHOD__
          else
            method_based_reader_for acs
          end
        end

        def method_based_reader_for acs
          Method_based_reader_for___[ self, acs ]
        end

        def via_name_and_model nf, mdl

          _begin_definition._init_via nf, mdl
        end

        alias_method :_begin_definition, :new
        private :new
      end  # >>
      METHOD__ = :component_association_reader


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

      def model_classifications
        @___cx ||= ___build_model_classifications
      end

      def ___build_model_classifications

        mdl = @component_model

        m = CONSTRUCTOR_METHODS__.detect { | m_ | mdl.respond_to? m_ }

        if m
          Model_Looks_Entitesque___.new m

        elsif mdl.respond_to? :[]
          LOOKS_LIKE_PROC___
        else
          self._COVER_ME
        end
      end

      def say_no_method__

        # assume model does not look like proc - for use in raising e.g a
        # `NoMethodError` regarding an expected but missing construction
        # method. this exists partly because the platform is strange about
        # when it decides to include the class name in the message.

        a = CONSTRUCTOR_METHODS__.dup
        a.push :[]
        _s_a = a.map { | sym | "`#{ sym }`" }
        _or = Callback_::Oxford_or[ _s_a ]

        "must respond to #{ _or } - #{ @component_model.name }"
      end

      ENTITESQUE_CONSTRUCTOR_METHOD__ = :interpret_component

      CONSTRUCTOR_METHODS__ = [
        ENTITESQUE_CONSTRUCTOR_METHOD__,
        COMPOUND_CONSTRUCTOR_METHOD_,
      ]

      class Model_Looks_Entitesque___

        def initialize m
          @construction_method_name = m
        end

        def looks_compound
          COMPOUND_CONSTRUCTOR_METHOD_ == @construction_method_name
        end

        def looks_entitesque
          ENTITESQUE_CONSTRUCTOR_METHOD__ == @construction_method_name
        end

        attr_reader(
          :construction_method_name,
        )

        def looks_like_proc
          false
        end
      end

      module LOOKS_LIKE_PROC___ ; class << self

        def looks_compound
          false
        end

        def looks_entitesque
          false
        end

        def looks_like_proc
          true
        end
      end ; end

      # ~

      def description_under _expag
        @name.as_human
      end

      def accept__can__meta_component * i_a  # :t8.

        bx = Callback_::Box.new
        i_a.each do | sym |
          bx.add sym, :declared
        end
        @_operations = bx
        NIL_
      end

      attr_reader :_operations

      def accept__intent__meta_component sym  # see [#083]:#interp-B
        @intent = sym
        NIL_
      end

      attr_reader :intent

      def accept__stored_in_ivar__meta_component ivar

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

      def to_operation_symbol_stream  # assume operations
        @_operations.to_name_stream
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
    end

    module Reflection

      To_qualified_knownness_stream = -> acs do

        asc_for = Component_Association.reader_for acs

        qkn_for = ACS_::Reflection_::Reader[ acs ]

        ACS_::Reflection_::To_entry_stream[ acs ].map_reduce_by do | entry |

          if entry.is_association

            _asc = asc_for[ entry.name_symbol ]

            qkn_for[ _asc ]
          end
        end
      end

      To_component_association_name_symbol_stream = -> acs do
        ACS_::Reflection_::To_entry_stream[ acs ].map_by do | entry |
          entry.name_symbol
        end
      end

      Ivar_based_value_writer = -> acs do

        -> qkn do
          ACS_::Interpretation_::Write_via_ivar[ qkn, acs ]
        end
      end

      Ivar_based_value_reader = -> acs do

        # (similar but necessarily different from the other)

        -> asc do
          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            Value_Wrapper[ acs.instance_variable_get( ivar ) ]
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
