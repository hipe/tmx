module Skylab::Basic

  module String

    o = { }

    o[:string_begins_with_string_curry] = -> haystack_string do
      len = haystack_string.length
      -> needle_string do
        if needle_string.length <= len
          haystack_string[ 0, needle_string.length ] == needle_string
        end
      end
    end

    o[:string_is_at_end_of_string_curry] = -> needle_string do
      len = needle_string.length
      -> haystack_string do
        (( idx = haystack_string.rindex needle_string )) and
          idx == haystack_string.length - len
      end
    end

    FUN = ::Struct.new( * o.keys ).new( * o.values )
  end
end
