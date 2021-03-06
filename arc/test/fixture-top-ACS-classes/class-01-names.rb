module Skylab::Arc::TestSupport

  class Fixture_Top_ACS_Classes::Class_01_Names

    class Simple_Name

      class << self

        alias_method :new_cold_root_ACS_for_want_root_ACS, :new

        def interpret_compound_component p, & _  # #experimental [#003.F.2] compounds
          if p
            _me = new
            p[ _me ]
          else

            # the proc is not there IFF `null` was in the JSON payload. but
            # this is only experimental - remember that it is mechanically
            # impossible to result in false-ish validly from here, so we
            # will probably either make a major, earth-shattering change to
            # this #Tenet6 interface, or make `null` invalid in JSON payloads,
            # -OR- simply skip over nulls higher up (violating #DT1 autonomy)

            new
          end
        end

        private :new
      end  # >>

      attr_accessor(
        :first_name,
        :last_name,
      )

      def component_event_model  # experimental near [#006.C] event models
        :cold
      end

      def __first_name__component_association

        rx = /\A[A-Z]/

        -> st, & p_p do

          s = st.gets_one
          if rx =~ s
            Common_::KnownKnown[ s ]
          else

            _p = p_p[ nil ]

            _p.call :error, :expression, :no do | y |
              y << "can't be lowercase (had #{ ick s })"
            end
            false
          end
        end
      end

      def __last_name__component_association

        -> st, & p do

          _s = st.gets_one
          Common_::KnownKnown[ _s ]
        end
      end
    end

    class Credits_Name

      class << self
        alias_method :new_cold_root_ACS_for_want_root_ACS, :new
        private :new
      end  # >>

      attr_accessor(
        :nickname,
        :simple_name,
      )

      def component_event_model  # see [#006.C] event models
        :cold
      end

      def __nickname__component_association

        -> st, & _ do

          Common_::KnownKnown[ st.gets_one ]
        end
      end

      def __simple_name__component_association
        Simple_Name
      end
    end
  end
end
