module Skylab::Basic

  module FUN

    Inspect__ = -> length_d, x do
      # ( a trivial instance of [#it-002] summarization )
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

    Inspect = Inspect__.curry[ 10 ]  # a reasonably short length for a string

  end
end
