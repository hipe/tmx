module Skylab::Brazen

  module Autonomous_Component_System  # see [#089]

    class << self

      def argument_interpreter_via_normalization n11n

        -> arg_st, & oes_p do

          _trio = Callback_::Known.new_known arg_st.gets_one

          n11n.normalize_argument _trio do | * i_a, & ev_p |

            if oes_p
              oes_p[ * i_a, & ev_p ]
            else
              raise ev_p[].to_exception
            end
          end
        end
      end

      def create x_a, new_o, & x_p  # :t2.

        o = _Mutation_Session.new( & x_p )
        o.receive_argument_array x_a
        o.subject_component = new_o
        o.macro_operation_method_name = :create
        o.execute
      end

      def edit x_a, subj_o, & x_p  # :t3.

        o = _Mutation_Session.new( & x_p )
        o.receive_argument_array x_a
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

          mutation_event_class( :entity_already_added ).new_with(
            :entity, sub_comp,
            :entity_collection, subj_comp,
            :ok, nil  # overwrite to change error into info
          )
        end
        UNABLE_  # important
      end

      def entity_not_found sub_comp, subj_comp, & oes_p

        oes_p.call :error, :entity_not_found do

          mutation_event_class( :entity_not_found ).new_with(
            :entity, sub_comp,
            :entity_collection, subj_comp,
          )
        end
        UNABLE_  # important
      end

      def entity_removed sub_comp, subj_comp, & oes_p

        oes_p.call :info, :entity_removed do

          mutation_event_class( :entity_removed ).new_with(
            :entity, sub_comp,
            :entity_collection, subj_comp,
          )
        end
        ACHIEVED_  # ..?
      end

      def mutation_event_class sym
        _Mutation_Session.event_class sym
      end

      def _Mutation_Session
        ACS_::Sessions_::Mutation
      end
    end  # >>

    class Component_Association

      # different concerns will blow these up on demand

      class << self

        def via_symbol_and_component sym, comp

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
        @_operations_hash = nil
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

      attr_reader(
        :component_model,
        :name,
      )

      def __accept__can__meta_component * i_a  # :t8.

        @_operations_hash = ::Hash[ i_a.map { | k | [ k, true ] } ]
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

      def can sym
        if @_operations_hash
          @_operations_hash[ sym ]
        end
      end

      def operation_name_symbols
        h = @_operations_hash
        if h
          h.keys
        else
          EMPTY_A_
        end
      end
    end

    ACS_ = self
    Value_Wrapper = ::Struct.new :value_x
    Autoloader_[ Sessions_ = ::Module.new ]

  end
end
