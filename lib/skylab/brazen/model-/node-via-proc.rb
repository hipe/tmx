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

        def initialize k, action_class_like
          @action_class_like = action_class_like
          @kernel = k
        end

        attr_reader :action_class_like, :event_receiver, :kernel

        def members
          [ :action_class_like, :event_receiver, :kernel ]
        end

        def is_branch
          false  # for now
        end

        def bound_call_via_call x_a, er
          @event_receiver = er
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
          _ev = Brazen_::Entity.properties_stack.
            build_missing_required_properties_event(
              [ @custom_error.property ],
              'argument' )

          bc_via_error_event _ev
        end

        def bc_when_extra_arguments
          _ev = Brazen_::Entity.properties_stack.
            build_extra_properties_event [ @custom_error.x ], nil, 'argument', 'unexpected'

          bc_via_error_event _ev
        end

        def bc_via_error_event ev
          _ev_ = sign_event ev
          @event_receiver.receive_event _ev_
          UNABLE_
        end

        def sign_event ev
          _nf = @action_class_like.name_function
          Event_[].wrap.signature _nf, ev
        end

        def push_event_receiver_and_kernel_on_to_arglist
          @x_a.push @er, @k ; nil
        end
      end
    end
  end
end
