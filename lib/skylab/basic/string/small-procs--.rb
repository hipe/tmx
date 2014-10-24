module Skylab::Basic

  module String

    module Small_Procs__

    Build_proc_for_string_begins_with_string = -> haystack_string do
      len = haystack_string.length
      -> needle_string do
        if needle_string.length <= len
          haystack_string[ 0, needle_string.length ] == needle_string
        end
      end
    end

    Build_proc_for_string_ends_with_string = -> needle_string do
      len = needle_string.length
      -> haystack_string do
        (( idx = haystack_string.rindex needle_string )) and
          idx == haystack_string.length - len
      end
    end

      Looks_like_sentence = -> do

        _RX = /[.?!]\z/

        -> str do
          _RX =~ str
        end
      end.call

      Paragraph_string_via_message_lines = -> s_a do
        scan = Callback_.scan.via_nonsparse_array s_a
        s = scan.gets
        s and begin
          y = [ s ]
          while s = scan.gets
            if String_.looks_like_sentence y.last
              y.push SPACE_
            else
              y.push ". "
            end
            y.push s
          end
          y.join EMPTY_S_
        end
      end
    end
  end
end
