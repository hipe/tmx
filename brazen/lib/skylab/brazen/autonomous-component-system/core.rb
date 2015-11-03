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

    module CA_Builder__ ; class << self

      def single sym, acs
        _lookup( acs ).single sym, acs
      end

      def for acs
        _lookup( acs ).for acs
      end

      def _lookup acs
        if acs.respond_to? :lookup_component_association
          Dynamic_CA_Builder___
        else
          Conventional_CA_Builder
        end
      end
    end ; end

    class Common_CA_Builder__

      class << self
        def for acs
          new._init_for acs
        end
        private :new
      end  # >>

      def _init_for acs
        @_ACS = acs
        self
      end
    end

    class Dynamic_CA_Builder___ < Common_CA_Builder__

      def build_association_for sym
        @_ACS.lookup_component_association sym
      end
    end

    class Conventional_CA_Builder < Common_CA_Builder__

      class << self

        def single sym, acs

          _ca = Component_Association.new_prototype
          _ca._init_via_definition_method(
            Method_name_for__[ sym ],
            sym,
            acs )
        end
      end  # >>

      def _init_for acs
        @_prototype = Component_Association.new_prototype
        super
      end

      def build_association_for sym

        @_prototype.dup._init_via_definition_method(
          _method_name_for( sym ),
          sym,
          @_ACS
        )
      end

      def can_build_association_for sym
        @_ACS.respond_to? _method_name_for sym
      end

      Method_name_for__ = -> sym do
        :"__#{ sym }__component_association"
      end

      define_method :_method_name_for, Method_name_for__
    end

    class Component_Association

      # different concerns will construct these subject objects on demand
      # on-the-fly. for now internally we provide no way of memoizing them,
      # in contrast to [#001] properties which we took pains to freeze etc.
      # :[#089]:WISH-1: times when it feels wasteful to etc

      class << self

        def via_symbol_and_ACS sym, acs

          CA_Builder__.single sym, acs
        end

        def builder_for acs

          CA_Builder__.for acs
        end

        alias_method :new_prototype, :new
        private :new
      end  # >>

      def initialize
        @_name_mutation = nil
        @_operations = nil
      end

      def _init_via_definition_method m, sym, acs

        cm = acs.send m do | * x_a | # :t4.
          send :"__accept__#{ x_a.first }__meta_component", * x_a[ 1 .. -1 ]
          NIL_
        end

        if cm
          @component_model = cm

          nm = Callback_::Name.via_variegated_symbol sym

          if @_name_mutation
            @_name_mutation[ nm ]
          end

          @name = nm

          self
        else
          self._COVER_ME  # maybe one day c.a's can dynamically disappear
        end
      end

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
    end

    ACS_ = self
    Autoloader_[ Modalities = ::Module.new ]

    Value_Wrapper = -> x do
      Callback_::Known_Known[ x ]
    end
  end
end
