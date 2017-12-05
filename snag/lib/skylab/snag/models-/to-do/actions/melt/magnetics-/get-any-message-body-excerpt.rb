

self._THE_DEAL  # ..here is that we went ahead and re-wrote "melt" without
                # re-integrting this (our "scraps" file was such a mess..)
                # but it may be the case that the below is "better" than
                # the way we implemented it in the rewrite. so we are
                # keeping it around a little while longer

    class Get_any_message_body_excerpt__

      Home_::Model_::Actor[ self,
        :properties, :new_line, :todo_o ]

      def execute
        init
        work
        @message_body_excerpt
      end
    private
      def init
        @ellipsis = ELLIPSIS__
        @line_width = LINE_WIDTH__
        @min_words = MIN_WORDS__
        0 < @min_words or self._SANITY
      end

      def work
        @word_s_a = @todo_o.any_message_body_string.split SPACE_
        if @word_s_a.length.zero?
          @message_body_excerpt = nil
        else
          when_nonzero_number_of_words
        end
      end

      def when_nonzero_number_of_words
        @available_length = LINE_WIDTH__ - ( @new_line.length + SEP_.length )
        @excerpt_s = @word_s_a[ 0, @min_words - 1 ].join SPACE_
        @word_s_a[ 0, @min_words - 1 ] = EMPTY_A_
        if next_length > @available_length
          @message_body_excerpt = nil
        else
          flush
        end
      end

      def flush
        @message_body_excerpt = @excerpt_s  # success is guaranteed from here
        while @word_s_a.length.nonzero?
          accept_one
          _stop = next_length > @available_length
          _stop and break
        end
        if @word_s_a.length.nonzero?
          @excerpt_s.concat @ellipsis
        end ; nil
      end

      def next_length
        d = @excerpt_s.length
        if @word_s_a.length.nonzero?
          d.zero? or d += SPACE_.length
          d += @word_s_a.first.length
          1 < @word_s_a.length and d += @ellipsis.length
        end
        d
      end

      def accept_one
        @excerpt_s.length.nonzero? and _s = SPACE_
        @excerpt_s.concat "#{ _s }#{ @word_s_a.shift }" ; nil
      end

      ELLIPSIS__ = ' ..'.freeze
      LINE_WIDTH__ = Models::Manifest.line_width
      MIN_WORDS__ = 3  # (used to be marked with note in first tombstone)
    end

# :#tombstone MIN_WORDS__ = 3  # #note-210
