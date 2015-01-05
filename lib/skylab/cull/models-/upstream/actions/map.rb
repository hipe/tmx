module Skylab::Cull

  class Models_::Upstream

    Actions = ::Module.new

    class Actions::Map < Action_

      Brazen_.model.entity self,

          :ad_hoc_normalizer, -> arg, & oes_p do
            if arg.actuals_has_name
              Cull_.lib_.basic::Number.normalization.with(
                :argument, arg,
                :number_set, :integer,
                :minimum, 1,
                & oes_p )
            else
              arg
            end
          end,
          :default, 1,
          :property, :table_number,

          :property, :upstream_adapter,
          :required, :property, :upstream


      TABLE_NUMBER_PROPERTY = ___table_number_property_

      def accept_selective_listener_proc p
        @on_event_selectively = p ; nil
      end

      def produce_any_result
        @upstream = @parent_node.edit do | o |
          o.mutable_arg_box to_bound_argument_box_except :table_number
        end
        @upstream and via_upstream
      end

      def via_upstream

        st = @upstream.to_entity_stream_stream

        estream = nil
        count = 0

        @argument_box[ :table_number ].times do
          estream = st.gets
          estream or break
          count += 1
        end

        if estream
          estream
        else
          when_fell_short @argument_box[ :table_number ], count
        end
      end

      def when_fell_short wanted_number, had_number
        maybe_send_event :error, :early_end_of_stream do
          @upstream.event_for_fell_short_of_count wanted_number, had_number
        end
      end
    end
  end
end
