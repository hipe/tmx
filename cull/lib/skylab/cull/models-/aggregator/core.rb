module Skylab::Cull

  class Models_::Aggregator < Model_

    @after_name_symbol = :mutator

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_result
        Stream_[ Items__.constants ].map_by |const_i|
          Common_::Name.via_const_symbol const_i
        end
      end
    end

    module Items__
      Special_boxxy_[ self ]
    end
  end
end
