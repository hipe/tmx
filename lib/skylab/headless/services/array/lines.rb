module Skylab::Headless

  module Services::Array::Lines
  end

  class Services::Array::Lines::Producer

    # simple adapter for [#hl-044]

    def gets
      @gets.call
    end

    def line_number
      @line_number.call
    end

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
