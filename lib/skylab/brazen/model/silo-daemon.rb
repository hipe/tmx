module Skylab::Brazen

  class Model

    class Silo_Daemon

      def initialize kernel, model_class

        @kernel = kernel
        @model_class = model_class

        if @kernel.do_debug
          @kernel.debug_IO.puts(
            ">>          MADE #{ Callback_::Name.via_module( @model_class ).as_slug } SILO" )
        end
      end

      def members
        [ :model_class, :name_symbol ]
      end

      attr_reader :model_class

      def name_symbol
        @model_class.name_function.as_lowercase_with_underscores_symbol
      end

      def call * x_a, & oes_p
        bc = _bound_call_via x_a, & oes_p
        bc and bc.receiver.send( bc.method_name, * bc.args )
      end

      def bound_call * x_a, & oes_p
        _bound_call_via x_a, & oes_p
      end

      def _bound_call_via x_a, & oes_p

        sess = Brazen_::API.bound_call_session.start_via_iambic x_a, @kernel, & oes_p
        sess.receive_top_bound_node @model_class.new( @kernel, & oes_p )

        if sess.via_current_branch_resolve_action_promotion_insensitive
          st = sess.polymorphic_stream
          h = { trio_box: nil, preconditions: nil }
          while st.unparsed_exists
            if :with == st.current_token
              st.advance_one
              break
            end
            k = st.gets_one
            h.fetch k  # validate
            h[ k ] = st.gets_one
          end
          preconds = h[ :preconditions ]
          trio_box = h[ :trio_box ]
          h = nil

          act = sess.bound
          act.first_edit

          if preconds
            act.receive_starting_preconditions preconds
          end

          ok = true
          if trio_box
            ok = act.process_trio_box_passively__ trio_box
          end

          ok &&= act.process_polymorphic_stream_fully st
          ok and act.via_arguments_produce_bound_call
        else
          sess.bound_call
        end
      end

      # ~

      def any_mutated_formals_for_depender_action_formals x  # :+#public-API #hook-in

        # override this IFF your silo wants to add to (or otherwise mutate)
        # the formal properties of every client action that depends on you.

        my_name_sym = @model_class.node_identifier.full_name_symbol

        a = @model_class.preconditions
        if a and a.length.nonzero?
          x_ = x
          a.each do | silo_id |
            if my_name_sym == silo_id.full_name_symbol
              next
            end
            x__ = @kernel.silo_via_identifier( silo_id ).
              any_mutated_formals_for_depender_action_formals x_
            if x__
              x_ = x__
            end
          end
        end
        x_  # nothing by default
      end
    end
  end
end
