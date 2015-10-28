module Skylab::Brazen::TestSupport

  module Autonomous_Component_System::Support

    def self.[] tcc
      tcc.include self
    end

    def const_ sym
      Here_.const_get sym, false
    end

    def subject_
      ACS__[]
    end

    class Simple_Name

      attr_accessor(
        :first_name,
        :last_name,
      )

      def __first_name__component_association

        rx = /\A[A-Z]/

        -> st, & oes_p do

          s = st.gets_one
          if rx =~ s
            Home_::Autonomous_Component_System::Value_Wrapper[ s ]
          else
            oes_p.call :error, :expression, :no do | y |
              y << "no: #{ s }"
            end
            false
          end
        end
      end

      def __last_name__component_association

        -> st, & p do

          _s = st.gets_one
          ACS__[]::Value_Wrapper[ _s ]
        end
      end

      def self.interpret_component st, & _

        # (needed for making empty components for now)

        if st.unparsed_exists  # implement parsing null from json
          x = st.gets_one
          x.nil? or self._SANITY
        end

        st.unparsed_exists and self._SANITY

        new
      end
    end

    class Credits_Name

      attr_accessor(
        :nickname,
        :simple_name,
      )

      def __nickname__component_association

        -> st, & _ do

          ACS__[]::Value_Wrapper[ st.gets_one ]
        end
      end

      def __simple_name__component_association
        Simple_Name
      end
    end

    ACS__ = -> do
      Home_::Autonomous_Component_System
    end

    Here_ = self
  end
end
