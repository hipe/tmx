module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    module Class_01_thru_09

      class Class_04_One_Atom  # 0x

        def __ww_xx__component_association

          -> st, & _ do
            self._K
          end
        end
      end

      class Class_06_One_Entitesque  # 1x

        class << self
          alias_method :new_cold_root_ACS_for_iCLI_test, :new
          undef_method :new
        end  # >>

        def __sample__component_association

          Sample
        end
      end

      class Class_07_One_Compound  # 0x
        def __yy_zz__component_association
          Dummy_Compound_
        end
      end

      class Sample  # only used in this file (for now)

        # an exemplar entitesque

        class << self

          def interpret_component st, & pp

            s = st.head_as_is
            md = %r(\Asample[- ]rate: ?(\d+(?:\.\d+)?) ?kHz\z).match s
            if md
              d = md[ 1 ].to_f
              if 100 <= d
                st.advance_one
                new d
              else
                pp[ nil ].call :error, :expression do |y|
                  y << "kHz can't be less that 100 (had #{ ick d })"
                end
                UNABLE_
              end
            else
              pp[ nil ].call :error, :expression do |y|
                y << "was unparseable: #{ ick s }"
              end
              UNABLE_
            end
          end

          private :new
        end  # >>

        def initialize d
          @_d = d
        end

        def description_under _expag  # for expressive events
          "#{ @_d } kHz"
        end
      end
    end
  end
end
