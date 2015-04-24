module Skylab::Snag

  class Models_::Node

    class Actions::To_Stream < Common_Action

      edit_entity_class(

        :ad_hoc_normalizer, Normalize_ID_, :property, :identifier,

        :integer_greater_than_or_equal_to, 1,
        :description, -> y do
          y << 'limit output to N nodes'
        end,
        :property, :number_limit,

        :required, :property, :upstream_identifier
      )

      def produce_result
        resolve_node_collection_then_
      end

      def via_node_collection_

        h = @argument_box.h_
        id_o = h[ :identifier ]
        nc = @node_collection

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
