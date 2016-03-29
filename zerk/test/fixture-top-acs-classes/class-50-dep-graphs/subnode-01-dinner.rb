module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_50_Dep_Graphs::Subnode_01_Dinner

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        undef_method :new
      end  # >>

      def __get_card__component_operation
        -> money, & oes_p do
          if 5 <= money
            :_subway_card_
          else
            oes_p.call :error, :expression, :insufficient_funds do |y|
              y << "insufficient funds: need 5 had #{ ick money }"
            end
            UNABLE_
          end
        end
      end

      def __money__component_association
        Sibling_::Class_71_Number
      end

      def __take_subway__component_operation
        -> get_card do
          "using '#{ get_card }' you took subway"
        end
      end

      def __next_level__component_association

        Second_Level
      end

      class Second_Level

        class << self
          def interpret_compound_component p
            p[ new ]
          end
        end

        def __have_dinner__component_operation

          -> take_subway, money do
            "(dinner: you have $#{ money } (still!). #{ take_subway } here.)"
          end
        end
      end
    end
  end
end
