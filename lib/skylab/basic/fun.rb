module Skylab::Basic

  module FUN

    Inspect__ = -> length_d, x do  # :+[#it-002] summarization (trivial)
      if case x
      when ::NilClass, ::FalseClass, ::TrueClass, ::Numeric, ::Module
        true
      when ::String
        x.length < length_d
      end then
        x.inspect
      elsif ::Symbol === x
        "'#{ x }'"
      else
        "< a #{ x.class } >"
      end
    end

    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING = 10

    Inspect = Inspect__.curry[ A_REASONABLY_SHORT_LENGTH_FOR_A_STRING ]

  end
end
