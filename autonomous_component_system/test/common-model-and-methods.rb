module Skylab::Autonomous_Component_System::TestSupport

  module Common_Model_And_Methods

    def self.[] tcc
      tcc.include self
    end

    def const_ sym
      Here_.const_get sym, false
    end

    def subject_
      ACS__[]
    end

    Be_compound = -> cls do
      cls.class_exec do
        def self.interpret_compound_component p
          p[ new ]
        end
      end
    end

    Be_component = -> cls do
      cls.class_exec do
        def self.interpret_component st, & pp
          new st, & pp
        end
      end
    end

    class Simple_Name

      class << self

        def interpret_compound_component p, & _  # #experimental [#003]#compounds
          if p
            _me = new
            p[ _me ]
          else

            # the proc is not there IFF `null` was in the JSON payload. but
            # this is only experimental - remember that it is mechanically
            # impossible to result in false-ish validly from here, so we
            # will probably either make a major, earth-shattering change to
            # this #Tenet6 inteface, or make `null` invalid in JSON payloads,
            # -OR- simply skip over nulls higher up (violating #dt1 autonomy)

            new
          end
        end

        alias_method :new_empty_for_test_, :new
        private :new
      end

      attr_accessor(
        :first_name,
        :last_name,
      )

      def component_event_model  # experimental near [#006]:#Event-models
        :cold
      end

      def __first_name__component_association

        rx = /\A[A-Z]/

        -> st, & oes_p_p do

          s = st.gets_one
          if rx =~ s
            Home_::Value_Wrapper[ s ]
          else

            _oes_p = oes_p_p[ nil ]

            _oes_p.call :error, :expression, :no do | y |
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
    end

    class Credits_Name

      class << self
        alias_method :new_empty_for_test_, :new
        private :new
      end  # >>

      attr_accessor(
        :nickname,
        :simple_name,
      )

      def component_event_model  # see [#006]:#Event-models
        :cold
      end

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
      Home_
    end

    Here_ = self
  end
end
