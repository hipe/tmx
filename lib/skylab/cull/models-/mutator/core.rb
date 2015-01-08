module Skylab::Cull

  class Models_::Mutator < Model_

    @after_name_symbol = :map

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_any_result
        Callback_.stream.via_nonsparse_array Mutator_::Items__.constants do | const_i |
          Callback_::Name.via_const const_i
        end
      end
    end

    Autoloader_[ ( Items__ = ::Module.new ), :boxxy ]

    Mutator_ = self
  end
end