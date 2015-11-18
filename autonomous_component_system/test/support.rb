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

    Common_child_methods = -> cls do

      Common_child_class_methods[ cls ]

      cls.send :define_method, :initialize do | & x_p |
        @oes_p_ = x_p
      end
      NIL_
    end

    Common_child_class_methods = -> cls do
      class << cls
        define_method :interpret_component, INTERPRET_COMPONENT
        private :new
      end
      NIL_
    end

    INTERPRET_COMPONENT = -> st, & x_p do
      if st.unparsed_exists
        self._SANITY
      else
        new( & x_p )
      end
    end

    class Simple_Name

      class << self

        def interpret_compound_component p, & _  # experimental for [#083]:#interp-D
          if p
            _me = new
            p[ _me ]
          else

            # the proc is not there IFF `null` was in the JSON payload. but
            # this is only experimental - remember that it is mechanically
            # impossible to result in false-ish validly from here, so we
            # will probably either make a major, earth-shattering change to
            # this #t6 inteface make `null` invalid in JSON payloads, -OR-
            # imply skip over nulls higher up (violating #dt1 autonomy)

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

      def component_event_model  # experimental near [#085]:#Event-models
        :cold
      end

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

      def component_event_model  # see [#085]:#Event-models
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
      Home_::Autonomous_Component_System
    end

    Here_ = self
  end
end
