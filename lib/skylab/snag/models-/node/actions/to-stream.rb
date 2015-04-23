module Skylab::Snag

  class Models_::Node

    Actions = ::Module.new

    class Actions::To_Stream < Brazen_::Model.common_action_class

      Brazen_::Model.common_entity self,

        :ad_hoc_normalizer, -> arg, & oes_p do

          Snag_::Models_::Node_Identifier.
            interpret_out_of_under( arg, :User_Argument, & oes_p )

        end, :property, :identifier,

        :integer_greater_than_or_equal_to, 1,
        :description, -> y do
          y << 'limit output to N nodes'
        end,
        :property, :number_limit,

        :required, :property, :upstream_identifier

      def produce_result

        nc = @kernel.silo( :node_collection ).
          node_collection_via_upstream_identifier(
            @argument_box.fetch( :upstream_identifier ),
            & handle_event_selectively )

        nc and begin
          __via_node_collection nc
        end
      end

      def __via_node_collection nc

        h = @argument_box.h_
        id_o = h[ :identifier ]
        if id_o

         id_o.respond_to?( :suffix ) or self._SANITY  # prop needs a better name

          nc.entity_via_identifier_object id_o, & handle_event_selectively
        else

          st = nc.to_node_stream( & handle_event_selectively )
          st and begin
            d = h[ :number_limit ]
            if d
              __limit_by_count d, st
            else
              st
            end
          end
        end
      end

      def __limit_by_count end_, st

        count = 0

        Callback_::Stream.new st.upstream do

          if end_ > count
            x = st.gets
            if x
              count += 1
              x
            end
          end
        end
      end
    end
  end
end
