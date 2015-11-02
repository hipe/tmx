module Skylab::Brazen

  module Autonomous_Component_System  # see [#089]

    class << self

      def create x_a, new_o, & x_p  # :t2.

        o = _Mutation_Session.new( & x_p )
        o.accept_argument_array x_a
        o.subject_component = new_o
        o.macro_operation_method_name = :create
        o.execute
      end

      def edit x_a, subj_o, & x_p  # :t3.

        o = _Mutation_Session.new( & x_p )
        o.accept_argument_array x_a
        o.subject_component = subj_o
        o.macro_operation_method_name = :edit
        o.execute
      end

      def interpret arg_st, new_o, & x_p  # :+t6

        o = _Mutation_Session.new( & x_p )
        o.arg_st = arg_st
        o.subject_component = new_o
        o.macro_operation_method_name = :interpret
        o.execute
      end

      def entity_already_added sub_comp, subj_comp, & oes_p

        oes_p.call :error, :entity_already_added do

          event( :Entity_Already_Added ).new_with(
            :entity, sub_comp,
            :entity_collection, subj_comp,
            :ok, nil  # overwrite to change error into info
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

      def entity_removed cmp, asc, acs, & oes_p

        oes_p.call :info, :entity_removed do

          event( :Entity_Removed ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
          )
        end
        ACHIEVED_  # ..?
      end

      def event sym
        Home_::Events_.const_get sym, false
      end

      def _Mutation_Session
        ACS_::Mutation
      end
    end  # >>

    class Component_Association

      # different concerns will blow these up on demand
      # :[#089]:WISH-1: times when it feels wasteful to etc

      class << self

        def via_symbol_and_ACS sym, comp

          ca = new
          ca._init_for_component comp
          ca._init_for_sym sym
        end

        def builder_for comp

          proto = new
          proto._init_for_component comp
          -> sym do
            proto.dup._init_for_sym sym
          end
        end

        private :new
      end  # >>

      def initialize
        @_name_mutation = nil
        @_operations = nil
      end

      def _init_for_component comp
        @__component = comp
        NIL_
      end

      def _init_for_sym sym

        cm = remove_instance_variable( :@__component ).send(

          :"__#{ sym }__component_association"

        ) do | * x_a |  # :t4.
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

      def interpret arg_st, & x_p

        if @component_model.respond_to?(
            :interpret_component )  # :+t6

          x = @component_model.interpret_component(
            arg_st, & x_p )

          if x
            Value_Wrapper[ x ]
          else
            x
          end
        else
          @component_model[ arg_st, & x_p ]
        end
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
