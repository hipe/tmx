module Skylab::BeautySalon

  class Models::Line::Buffer

    def initialize num_chars_wide, flush_line
      num_chars_wide < 1 and fail "sanity - #{ num_chars_wide } chars wide?"
      line_a = [ ]
      curr_width = 0
      @puts_word = -> word do
        begin
          next_width = curr_width + word.length
          next_width += 1 if line_a.length.nonzero?
          case next_width <=> num_chars_wide
          when -1 ; line_a << word
                  ; curr_width = next_width
          when  0 ; line_a << word
                  ; @flush[]
          when  1 ; # adding the next word would put us over.
                  ; if line_a.length.nonzero?
                      @flush[]
                      redo
                    end
                    # adding the next word would put us over, *and* it's
                    # the first word on the line!
                    a = word[ 0, num_chars_wide ]
                    b = word[ num_chars_wide .. -1 ]
                    line_a << a
                    @flush[]
                    word = b
                    redo
          end
        end while nil
        nil
      end
      @flush = -> do
        if line_a.length.nonzero?
          line = "#{ line_a * ' ' }\n"  # (we allowed room to be cute w/ nl)
          line_a.clear
          flush_line[ line ]
          line_a.length
          curr_width = 0
        end
      end
    end

    def << x
      @puts_word[ x ]
      nil
    end

    def flush
      @flush[ ]
      nil
    end
  end
end
