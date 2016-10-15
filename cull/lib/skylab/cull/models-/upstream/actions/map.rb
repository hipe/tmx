module Skylab::Cull

  class Models_::Upstream

    class Actions::Map < Action_

      Brazen_::Modelesque.entity self,

          :ad_hoc_normalizer, -> qkn, & oes_p do
            if qkn.is_known_known
              Home_.lib_.basic::Number.normalization.with(
                :qualified_knownness, qkn,
                :number_set, :integer,
                :minimum, 1,
                & oes_p )
            else
              qkn.to_knownness
            end
          end,
          :default, 1,
          :property, :table_number,

          :property, :upstream_adapter,
          :required, :property, :upstream

      TABLE_NUMBER_PROPERTY = properties.fetch :table_number

      def produce_result
        @upstream = @parent_node.edit do | o |
          o.mutable_qualified_knownness_box to_qualified_knownness_box_except__ :table_number
        end
        @upstream and via_upstream
      end

      def via_upstream
        @upstream.entity_stream_at_some_table_number @argument_box[ :table_number ]
      end
    end
  end
end
