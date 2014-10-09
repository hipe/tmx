module Skylab::Basic

  class List::Scanner

    module With::Peek

      # list scanner with peek
      # like this:
      #
      #     scn = Basic::List::Scanner[ %i( a b ) ]
      #     Basic::List::Scanner::With[ scn, :peek ]
      #     scn.gets  # => :a
      #     scn.peek  # => :b
      #     scn.gets  # => :b
      #     scn.peek  # => nil

      to_proc = -> _ do

        alias_method :gets_before_peek, :gets
        def gets
          peeker.gets
        end
        def peek
          peeker.peek
        end
      private
        def peeker
          @peeker ||= Peeker__.new self
        end ; nil
      end ; define_singleton_method :to_proc do to_proc end

      class Peeker__
        def initialize x
          @is_buffered = false
          @scn = x ; nil
        end
        def gets
          if @is_buffered
            @is_buffered = false
            r = @x ; @x = nil ; r
          else
            @scn.gets_before_peek
          end
        end
        def peek
          @is_buffered || buffer
          @x
        end
      private
        def buffer
          @is_buffered = true
          @x = @scn.gets_before_peek ; nil
        end
      end
    end
  end
end
