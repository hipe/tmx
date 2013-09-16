module Skylab::Basic

  module FUN

    Inspect = -> x do
      # ( a trivial instance of [#it-001] summarization )
      if case x
      when ::NilClass, ::FalseClass, ::TrueClass, ::Numeric, ::Module
        true
      when ::String
        x.length < A_REASONABLY_SHORT_LENGTH_FOR_A_STRING__
      end then
        x.inspect
      elsif ::Symbol === x
        "'#{ x }'"
      else
        "< a #{ x.class } >"
      end
    end
    #
    A_REASONABLY_SHORT_LENGTH_FOR_A_STRING__ = 10

  end
end
