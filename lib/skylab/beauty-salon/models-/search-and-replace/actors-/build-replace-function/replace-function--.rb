module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class Replace_Function__

        def initialize * a
          @function_a, @on_event_selectively = a
        end

        def call md
          output_s_a = []
          ok = true
          @function_a.each do |function|
            s = function.call md
            if s
              output_s_a.push s
            else
              ok = s
              break
            end
          end
          ok and begin
            output_s_a * EMPTY_S_
          end
        end
      end
    end
  end
end
