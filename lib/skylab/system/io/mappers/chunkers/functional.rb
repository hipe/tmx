module Skylab::Headless

  module IO

    module Mappers

      module Chunkers

        Functional = Headless_.lib_.ivars_with_procs_as_methods.
            new :flush, :write do

          def << x
            write x
            self
          end

    def initialize f
      sep = NEWLINE_
      cache_a = [ ]
      @write = -> str do
        if str.length.nonzero?
          off = 0 ; len = str.length ; last = len - 1
          idx = str.index sep, off
          if idx.nil?
            cache_a << str.dup
          else
            cache_a << str[ 0 .. idx ]  # including separator
            f[ cache_a * EMPTY_S_ ]
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
          s = cache_a * EMPTY_S_
          cache_a.clear
          f[ s ]
          s.length
        end
      end
      nil
    end

        end
      end
    end
  end
end
