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
        @upstream.entity_stream_at_some_table_number @argument_box[ :table_number ]
      end
    end
  end
end
