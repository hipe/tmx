module Skylab::Brazen::TestSupport

  module Autonomous_Component_System::Support

    def self.[] tcc
      tcc.include self
    end

    def const_ sym
      Here_.const_get sym, false
    end

    def subject_
      Home_::Autonomous_Component_System
    end

    class Simple_Name

      attr_accessor(
        :first_name,
        :last_name,
      )

      def __first_name__component_association
        :_trueish_
      end

      def __last_name__component_association
        :_trueish_
      end
    end

    class Credits_Name

      attr_accessor(
        :nickname,
        :simple_name,
      )

      def __nickname__component_association
        :_trueish_
      end

      def __simple_name__component_association
        Simple_Name
      end
    end

    Here_ = self
  end
end
