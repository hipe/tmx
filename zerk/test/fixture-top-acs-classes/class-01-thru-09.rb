module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    module Class_01_thru_09

      class Class_04_One_Atom

        def __ww_xx__component_association

          -> st, & _ do
            self._K
          end
        end
      end

      class Class_06_One_Entity
        def __xx_yy__component_association
          Dummy_Entity_
        end
      end

      class Class_07_One_Compound
        def __yy_zz__component_association
          Dummy_Compound_
        end
      end
    end
  end
end
