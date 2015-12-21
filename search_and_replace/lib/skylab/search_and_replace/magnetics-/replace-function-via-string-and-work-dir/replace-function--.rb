module Skylab::SearchAndReplace

    class Magnetics_::Replace_Function_via_String_and_Work_Dir

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

        def as_text
          @function_a.map do |x|
            x.as_text
          end * EMPTY_S_
        end

        def marshal_dump
          @function_a.map do |x|
            x.marshal_dump
          end * EMPTY_S_
        end
      end
    end
  # -
end
