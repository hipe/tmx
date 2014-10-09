module Skylab::Basic

  module String

    FUN = ::Module.new

    FUN::Build_proc_for_string_begins_with_string = -> haystack_string do
      len = haystack_string.length
      -> needle_string do
        if needle_string.length <= len
          haystack_string[ 0, needle_string.length ] == needle_string
        end
      end
    end

    FUN::Build_proc_for_string_ends_with_string = -> needle_string do
      len = needle_string.length
      -> haystack_string do
        (( idx = haystack_string.rindex needle_string )) and
          idx == haystack_string.length - len
      end
    end

    MUSTACHE_RX = / {{ ( (?: (?!}}) [^{] )+ ) }} /x

  end
end
