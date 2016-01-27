module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_04_Just_a_Primitive

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        private :new
      end  # >>

      def __file_name__component_association
        Here_::Class_71_File_Name
      end

      # -- just for the tests

      def set_file_nerm x
        @file_name = x ; nil
      end

      def read_file_nerm
        @file_name
      end

      def hello
        :_hi_
      end
    end
  end
end
