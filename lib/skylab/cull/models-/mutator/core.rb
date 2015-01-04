module Skylab::Cull

  class Models_::Mutator < Model_

    @after_name_symbol = :upstream

    Actions = ::Module.new

    class Actions::List < Action_

      # ~ ick for now

      def formal_properties
        nil
      end

      def any_formal_property_via_symbol sym
        nil
      end

      # end ick

      def produce_any_result
        Callback_.stream.via_nonsparse_array Mutator_::Items__.constants do | const_i |
          Callback_::Name.via_const const_i
        end
      end
    end

    Autoloader_[ ( Items__ = ::Module.new ), :boxxy ]

    Mutator_ = Models_::Mutator
  end
end
