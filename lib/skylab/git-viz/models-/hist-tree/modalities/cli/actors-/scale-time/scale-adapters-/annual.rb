module Skylab::GitViz

  class Models_::HistTree

    module Modalities::CLI

      class Actors_::Scale_time

        class Scale_Adapters_::Annual < Scale_time_::Common_Scale_Adapter_

          class << self

            def next
              :Singularity  # #todo
            end

            def within_ sumzn

              within__ sumzn.downstream, sumzn.subject, sumzn.width
            end

            def within__ downstream, subject, width

              send :"__within__#{ width }__", downstream, subject
            end

            def __within__4__ downstream, o

              downstream << o.normal_datetime.year.to_s  # etc

              NIL_
            end

          end  # >>

          DAYS_PER_BUCKET = 365  # :+#what-about-leap-year

          INTERNAL_UNIT = :year

        end
      end
    end
  end
end
