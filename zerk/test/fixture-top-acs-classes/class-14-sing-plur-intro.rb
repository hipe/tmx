module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_14_Sing_Plur_Intro  # 1x

      class << self
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        undef_method :new
      end  # >>

      def initialize
        @foobizzles = nil  # just so no warning on one test
      end

      def __foobizzle__component_association

        yield :is_singular_of, :foobizzles

        Primitivesque_model_for_trueish_value_
      end

      def __foobizzles__component_association

        yield :is_plural_of, :foobizzle

        Primitivesque_model_for_trueish_value_
      end

      def __no_args__component_operation

        -> do
          "(yasure: #{ @foobizzles.inspect })"
        end
      end

      def __sing_as_arg__component_operation

        # by design, throws when called. but not covered for now.

        -> foobizzle do
          self._NEVER_SEE
        end
      end

      def __plur_as_arg__component_operation

        -> foobizzles do
          "(youbetcha: #{ foobizzles.inspect })"
        end
      end
    end
  end
end
