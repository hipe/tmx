module Skylab::TMX::TestSupport

  module FixtureDirectories::Dir_02_WithAttributes

    module Attriboots

      class SomeNumber

        def initialize(*)

        end
      end

      class Square

        def initialize(*)

        end

        def derived_from
          :some_number
        end

        def begin_deriver
          SquareDeriver___.new
        end

        # ==
        class SquareDeriver___
          def see_and_or_mutate_for_derivation node
            bx = node.box
            d = bx.fetch :some_number
            bx.add :square, ( d ** 2 )
            NIL
          end
        end
        # ==
      end
    end
  end
end
