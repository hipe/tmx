module Skylab::Brazen

  class Model_

    module Node_via_Proc

      # #todo - node via proc is covered elsewhere: [tm], [cu]

      class << self

        def produce_action_class_like p, const_sym, parent_mod
          ActionClassLike__.new( p,
            "#{ parent_mod.name }#{ CONST_SEP_ }#{ const_sym }",
            parent_mod )
        end

        def produce_nodelike p, i, mod
          NodeLike__.new p, i, mod
        end
      end

      class NodeLike__

        def initialize p, i, mod
          @name_s = "#{ mod.name }#{ CONST_SEP_ }#{ i }"
          @mod = mod
          @i = i
          @p = p
        end

        def name  # result is string only because we are emulating ::Module#name
          @name_s
        end

        def to_upper_unbound_action_stream
          Callback_.stream.via_item ActionClassLike__.new( @p, @name_s, @mod )
        end
      end

      class ActionClassLike__

        include NAME_LIBRARY_.name_function_proprietor_methods

        def initialize p, name_s, mod
          @parent_module = mod
          @name_s = name_s
          @p = p
        end

        def is_branch
          false
        end

        def is_actionable
          true
        end

        def is_promoted
          true  # meh
        end

        attr_reader :p, :parent_module

        def members
          [ :name_function, :parent_module ]
        end

        def name_function
          super
        end

        def name_function_class  # #hook-in
          Brazen_.model.action_class.name_function_class
        end

        def custom_action_inflection
          nil
        end

        def name
          @name_s
        end

        def new k , & oes_p
          CallLike__.new k, self, & oes_p
        end

      private

        def some_name_stop_index
          @did_search_for_name_stop_index ||= search_for_name_stop_index
          @name_stop_index
        end

        def search_for_name_stop_index

          # assume convention: insist that some nearest module has the
          # 'Action_' const (probably the application node), and insist
          # that the Action_ node has the name stop index const.

          chain = LIB_.module_lib.chain_via_module @parent_module
          _mod = ( chain.length - 1 ).downto( 0 ).reduce nil do |_, d|
            if chain.fetch( d ).value_x.const_defined? :Action_
              break chain[ d ].value_x
            end
          end
          @name_stop_index = _mod::Action_::NAME_STOP_INDEX
          true
        end
      end

      class CallLike__

        class << self
          def after_name_symbol
            # for now
          end

          def is_branch
            false
          end
        end

        def initialize k, action_class_like, & oes_p
          @action_class_like = action_class_like
          @kernel = k
          @on_event_selectively = oes_p
        end

        attr_reader :action_class_like, :kernel

        def members
          [ :action_class_like, :kernel, :maybe_receive_event ]
        end

        def is_visible
          true  # for now
        end

        def accept_parent_node_ _
        end

        def name
          @action_class_like.name_function
        end

        def has_description
          # for now
        end

        def formal_properties
          Mock_Formal_Properties__.new do
            __parameter_box.to_value_stream
          end
        end

        def any_formal_property_via_symbol sym
          __parameter_box[ sym ]
        end

        def __parameter_box
          @pbx ||= bld_parameter_box
        end

        def bld_parameter_box

          params = @action_class_like.p.parameters

          params.pop  # because #here

          bx = Callback_::Box.new
          params.each do | opt_req_rest, name_symbol |

            case opt_req_rest
            when :req
              parameter_arity = :one
            else
              raise ::NoMethodError, opt_req_rest
            end

            bx.add( name_symbol,

            Brazen_.model.entity::Entity_Property.new do

              @name = Callback_::Name.via_variegated_symbol name_symbol
              @parameter_arity = parameter_arity

            end )
          end
          bx
        end

        class Mock_Formal_Properties__
          def initialize & p
            @p = p
          end
          def to_stream
            @p.call
          end
        end

        def ___bound_call_via_iambic_stream_and_modality_adapter___ st, x
          bound_call_against_iambic_stream st
        end

        def bound_call_against_iambic_stream st
          case 0 <=> @action_class_like.p.arity
          when -1 ; bc_when_nonzero_arity_via_stream st
          when  0 ; bc_when_zero_arity
          when  1 ; bc_when_glob st
          end
        end

        def __REDO_bc_when_zero_arity
          Brazen_.bound_call nil, @action_class_like.p, :call
        end

        def __REDO_bc_when_glob st
          x_a.push self
          Brazen_.bound_call x_a, @action_class_like.p, :call
        end

        def bc_when_nonzero_arity_via_stream st

          param_a = @action_class_like.p.parameters
          param_a[ -1, 1 ] = EMPTY_A_  # always 1 arg for the call used #here

          mutable_iambic = st.array_for_read[ st.current_index .. st.x_a_length - 1 ]

          any_custom_err = Brazen_::CLI.arguments.normalization.via(
            :parameters, param_a ).
              any_error_event_via_validate_x( mutable_iambic )

          if any_custom_err
            bc_when_custom_error any_custom_err
          else
            bc_when_OK mutable_iambic
          end
        end

        def bc_when_OK mutable_iambic

          mutable_iambic.push self  # :#here is where we use the 1 extra arg

          Brazen_.bound_call mutable_iambic, @action_class_like.p, :call
        end

        def bc_when_custom_error err
          @custom_error = err
          send :"bc_when_#{ err.terminal_channel_i }_arguments"
        end

        def bc_when_missing_arguments
          maybe_send_event :error do
            bld_missing_arguments_event
          end
          UNABLE_
        end

        def bld_missing_arguments_event
          _ev = Brazen_::Entity.properties_stack.
            build_missing_required_properties_event(
              [ @custom_error.property ],
              'argument' )
          _sign_event _ev
        end

        def bc_when_extra_arguments
          maybe_send_event :error do
            bld_when_extra_arguments_event
          end
          UNABLE_
        end

        private def maybe_send_event * i_a, & ev_p
          @on_event_selectively[ * i_a, & ev_p ]
        end

        def maybe_receive_event * i_a, & ev_p
          @on_event_selectively[ * i_a, & ev_p ]
        end

        def bld_when_extra_arguments_event
          _ev = Brazen_::Entity.properties_stack.
            build_extra_properties_event [ @custom_error.x ], nil, 'argument', 'unexpected'

          _sign_event _ev
        end

        def _sign_event ev
          _nf = @action_class_like.name_function
          Brazen_.event.wrap.signature _nf, ev
        end
      end
    end
  end
end
