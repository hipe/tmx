module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        class Scale_Adapters_::Semi_Annual < Scale_time_::Common_Scale_Adapter_

          class << self

            def next
              :Annual
            end
          end  # >>

          DAYS_PER_BUCKET = Rational 365, 2  # :+#what-about-leap-year

          INTERNAL_UNIT = :half

          def within__4__ sumzn

            # given such few characters as 4 to work within, it may or may
            # not be the case that for every first half of every year, the
            # four characters are taken up by displaying the year and do
            # not ever get expression dedicated to expressing which half.

            if 6 < sumzn.subject.normal_datetime.month

              sumzn.downstream << SECOND_HALF_IN_FOUR___
            else
              sumzn.downstream << self.FIRST_HALF_IN_FOUR___
            end
            NIL_
          end

          SECOND_HALF_IN_FOUR___ = "2nd\u00bd"  # ½ - Vulgar Fraction One Half
        end
      end
    end
  end
end
