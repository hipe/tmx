module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_11_Minimal_Postfix  # 4x

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        alias_method :new_cold_root_ACS_for_iCLI_test, :new
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        private :new
      end  # >>

      def __left_number__component_association

        Sibling_::Class_71_Number
      end

      def __right_number__component_association

        Sibling_::Class_71_Number
      end

      def __add__component_operation

        -> left_number, right_number do
          left_number + right_number
        end
      end

      # --

      def set_left_number_ x
        @left_number = x ; nil
      end

      def read_left_number_
        @left_number
      end

      def hello
        :_hi_
      end
    end
  end
end
