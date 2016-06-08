module Skylab::Cull

  class Models_::Aggregator < Model_

    @after_name_symbol = :mutator

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_result
        Common_::Stream.via_nonsparse_array Aggregator_::Items__.constants do | const_i |
          Common_::Name.via_const_symbol const_i
        end
      end
    end

    Autoloader_[ ( Items__ = ::Module.new ), :boxxy ]

    Aggregator_ = self

  end
end
