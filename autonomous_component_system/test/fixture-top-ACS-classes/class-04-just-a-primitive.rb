module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_04_Just_a_Primitive

      def __file_name__component_association
        Here_::Class_71_File_Name
      end

      # -- necessary for unmarshal

      def component_event_model
        :hot
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
