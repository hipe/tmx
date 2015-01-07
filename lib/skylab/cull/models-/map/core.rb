module Skylab::Cull

  class Models_::Map < Model_

    @after_name_symbol = :upstream

    Actions = ::Module.new

    class Actions::List < Action_

      def produce_any_result
        Callback_.stream.via_nonsparse_array Map_::Items__.constants do | const_i |
          Callback_::Name.via_const const_i
        end
      end
    end

    Autoloader_[ ( Items__ = ::Module.new ), :boxxy ]

    Map_ = self

  end
end
