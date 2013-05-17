module Skylab::Headless

  module Services::Array::Lines
    # [#067] - merge that into this
    # (i mean Basic)
  end

  Services::Array::Lines::Producer = MetaHell::Function::Class.new(
     :gets, :line_number )

  class Services::Array::Lines::Producer

    # simple adapter for [#hl-044]

    def initialize ary
      pos = -1
      @gets = -> do
        if ( pos + 1 ) < ary.length
          ary[ pos += 1 ]
        end
      end
      @line_number = -> do
        if -1 < pos
          pos + 1
        end
      end
    end
  end
end
