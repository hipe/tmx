module Skylab::Cull

  class Models_::Mutator < Model_

    @after_name_symbol = :map

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_result
        Stream_[ Mutator_::Items__.constants ].map_by do |const_i|
          Common_::Name.via_const_symbol const_i
        end
      end
    end

    module Items__
      Special_boxxy_[ self ]
    end

    Mutator_ = self
  end
end
