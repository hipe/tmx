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

    Mutator_ = self

    class << self

      def func_and_args_and_category_via_call_expression s, & p

        Mutator_::Models__::Unmarshal.new( & p ).three_via_qualified_call_expression s

      end

      def func_and_args_via_call_expression_and_module s, mod, & p

        Mutator_::Models__::Unmarshal.new( & p ).two_via_call_expression_and_module s, mod

      end
    end
  end
end
