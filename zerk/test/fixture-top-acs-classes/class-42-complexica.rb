module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_42_Complexica  # 3x

      # there are three compounds. each compound has one primitivesque
      # and one operation. the root compound has a next compound and that
      # next compound in turn has a next compound. (but that last compound
      # is the topmost one.) this totals around 9 nodes with 8 edges.

      class << self
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        private :new
      end  # >>

      def __compo2__component_association

        yield :description, -> y do
          y << highlight( 'C2' )
        end

        Compound_2
      end

      def __ope1__component_operation

        yield :description, -> y do
          y << highlight( 'OPE1' )
          y << '(second line)'
        end

        -> do
          self._NOT_called
        end
      end

      def __primi1__component_association
        -> do
          self._NOT_called_2
        end
      end

      class Compound_2

        def self.interpret_compound_component p, & _pp
          p[ new ]
        end

        def initialize
          @_pval = nil
        end

        def __compo3__component_association
          Compound_3
        end

        def __ope2__component_operation
          -> & p do
            if @_pval
              self._K
            else

              p.call :info, :expression do |y|
                y << "hello from ope2 with #{ highlight 'no' } params set."
              end

              NOTHING_  # don't express anything else besided the above
            end
          end
        end

        def __primi2__component_association
          Primitivesque_model_for_trueish_value_
        end

        def __primi2
          @primi2
        end
      end

      class Compound_3

        class << self

          # (implement the simplest form of breaking autonomy..)

          def interpret_compound_component p, _my_assoc, parent_ACS, & _pp
            p[ new parent_ACS ]
          end

          private :new  # for sanity
        end  # >>

        def describe_into_under y, expag
          expag.calculate do
            y << highlight( 'C3' )
          end
        end

        def initialize parent
          @_parent = parent
        end

        def __ope3__component_operation

          -> & p do

            _ = @_parent.__primi2
            __ = @primi3

            p.call :info, :expression do |y|
              y << "(p2: #{ _ }, p3: #{ __ })"
            end

            NOTHING_
          end
        end

        def __primi3__component_association
          Primitivesque_model_for_trueish_value_
        end
      end
    end
  end
end
