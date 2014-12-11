module Skylab::Brazen

  class Model_

    module Node_via_Proc

      class << self

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

        def get_unbound_upper_action_scan
          Callback_.scan.via_item ActionClassLike__.new( @p, @i, @name_s, @mod )
        end
      end

      class ActionClassLike__

        include NAME_LIBRARY_.name_function_proprietor_methods

        def initialize p, i, name_s, mod
          @parent_module = mod
          @name_s = name_s
          @p = p
        end

        attr_reader :p, :parent_module

        def members
          [ :name_function, :parent_module ]
        end

        def name
          @name_s
        end

        def new k
          CallLike__.new k, self
        end

      private

        def some_name_stop_index
          @did_search_for_name_stop_index ||= search_for_name_stop_index
          @name_stop_index
        end

        def search_for_name_stop_index

          # assume convention: insist that some nearest module has the
          # 'Actions_' const (probably the application node), and insist
          # that the Actions_ node has the name stop index const.

          chain = Brazen_::Lib_::Module_lib[].chain_via_module @parent_module
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
          def after_i
            # for now
          end
        end

        def initialize k, action_class_like
          @action_class_like = action_class_like
          @kernel = k
        end

        attr_reader :action_class_like, :kernel

        def members
          [ :action_class_like, :kernel ]
        end

        def is_branch
          false  # for now
        end

        def is_visible
          true  # for now
        end

        def accept_parent_node _
        end

        def name
          @action_class_like.name_function
        end

        def has_description
          # for now
        end

        def bound_call_via_call x_a, & oes_p
          @on_event_selectively = oes_p
          case 0 <=> @action_class_like.p.arity
          when -1 ; bc_when_nonzero_arity x_a
          when  0 ; bc_when_zero_arity
          when  1 ; bc_when_glob x_a
          end
        end

        def bc_when_zero_arity
          Brazen_.bound_call nil, @action_class_like.p, :call
        end

        def bc_when_glob x_a
          x_a.push self
          Brazen_.bound_call x_a, @action_class_like.p, :call
        end

        def bc_when_nonzero_arity x_a

          param_a = @action_class_like.p.parameters
          param_a[ -1, 1 ] = EMPTY_A_  # always 1 arg for the call used #here

          _n11n = Brazen_::CLI.arguments.normalization.via :parameters, param_a
          any_custom_err = _n11n.any_error_event_via_validate_x x_a

          if any_custom_err
            bc_when_custom_error any_custom_err
          else
            bc_when_OK x_a
          end
        end

        def bc_when_OK x_a
          x_a.push self  # :#here is where we use the 1 extra arg
          Brazen_.bound_call x_a, @action_class_like.p, :call
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
