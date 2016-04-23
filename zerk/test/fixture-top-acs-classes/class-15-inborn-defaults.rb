module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_15_Inborn_Defaults  # 1x

      class << self
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        undef_method :new
      end  # >>

      def initialize
        @files = [ '~/defaulto' ]
      end

      def __files__component_association

        yield :is_plural_of, :file
      end

      def __file__component_association

        yield :is_singular_of, :files

        Primitivesque_model_for_trueish_value_
      end

      def __as_opts__component_operation

        -> do
          "(files: #{ @files.inspect })"
        end
      end
    end
  end
end
