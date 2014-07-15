module Skylab::Headless

  IO::Interceptors::Chunker::F = Headless_::Lib_::Function_class[].
    new( :flush, :write ) do

    # #todo

    def initialize f
      sep = "\n"
      cache_a = [ ]
      @write = -> str do
        if str.length.nonzero?
          off = 0 ; len = str.length ; last = len - 1
          idx = str.index sep, off
          if idx.nil?
            cache_a << str.dup
          else
            cache_a << str[ 0 .. idx ]  # including separator
            f[ cache_a * EMPTY_STRING_ ]
            cache_a.clear
            off = idx + 1
            while off < len
              idx = str.index sep, off
              if idx
                f[ str[ off .. idx ] ]
                off = idx + 1
              else
                cache_a << str[ off .. last ]
                break
              end
            end
          end
        end
        nil
      end
      @flush = -> do
        if cache_a.length.nonzero?
          s = cache_a * EMPTY_STRING_
          cache_a.clear
          f[ s ]
          s.length
        end
      end
      nil
    end

    alias_method :<<, :write
  end
end
