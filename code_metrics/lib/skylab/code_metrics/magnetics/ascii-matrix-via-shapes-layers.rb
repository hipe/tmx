module Skylab::CodeMetrics

  class Magnetics::AsciiMatrix_via_ShapesLayers < Common_::Actor::Monadic

    def initialize sl
      @shapes_layers = sl
    end

    def execute

      _big_string = <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
      HERE

      _st = Home_.lib_.basic::String.line_stream _big_string

      _st   # #todo
    end
  end
end
# #born as mock
