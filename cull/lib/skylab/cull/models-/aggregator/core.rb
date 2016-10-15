module Skylab::Cull

  class Models_::Aggregator < Model_

    @after_name_symbol = :mutator

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_result
        Common_::Stream.via_nonsparse_array Items__.constants do | const_i |
          Common_::Name.via_const_symbol const_i
        end
      end
    end

    module Items__
      Special_boxxy_[ self ]
    end
  end
end
