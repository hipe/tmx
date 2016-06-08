module Skylab::Common

  module Scn__

    class Peek__

      # hack a minimal scanner to also respond to a `peek` method
      # like this
      #
      #     _scn = Basic_::List.line_stream %i( a b )
      #     scn = Home_::Scn.peek.gets_under _scn
      #     scn.gets  # => :a
      #     scn.peek  # => :b
      #     scn.gets  # => :b
      #     scn.peek  # => nil


      class << self

        def gets_under scn
          new scn
        end
      end

      def initialize scn
        @is_buffered = false
        @upstream = scn
      end

      def gets
        if @is_buffered
          @is_buffered = false
          x = @buffer_x
          @buffer_x = nil
          x
        else
          @upstream.gets
        end
      end

      def peek
        if ! @is_buffered
          @is_buffered = true
          @buffer_x = @upstream.gets  # might be false-ish
        end
        @buffer_x
      end
    end
  end
end
