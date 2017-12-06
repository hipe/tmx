module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Reverse_Throughput_Line_Stream_via_Static_Block

    # providing N number of lines from the end is trivial with a static block.

    def initialize charpos, ltss, big_string
      @big_string = big_string
      @charpos = charpos
      @LTSs = ltss
    end

    def execute

      a = @LTSs

      @_stream = Common_::Stream.via_range( ( a.length - 1 ) .. 0 ) do |d|
        a.fetch d
      end

      @_current_LTS = @_stream.gets  # assume at least one

      @_state = :__main

      Common_.stream do
        send @_state
      end
    end

    def __main

      lts = @_stream.gets
      if lts
        a = [ :static_continuing ]
        cursor_d = lts.end_charpos
      else
        # once you are out of newlines from your reverse stream, then
        # you are at the first line of the static block.
        a = [ :static ]
        cursor_d = @charpos
      end

      lts_ = remove_instance_variable :@_current_LTS
      cursor_d_ = lts_.charpos
      if cursor_d != cursor_d_
        a.push :content, @big_string[ cursor_d ... cursor_d_ ]
        cursor_d = cursor_d_
      end

      @big_string[ cursor_d ... lts_.end_charpos ] == lts_.string or self._SANITY  # #todo

      a.push :LTS_begin, lts_.string, :LTS_end

      if lts
        @_current_LTS = lts
      else
        @_state = :___done
      end

      Throughput_Line___.new a
    end

    def ___done
      NOTHING_
    end

    # ==

    class Throughput_Line___  # compare to same-name counterpart

      def initialize a
        @a = a
      end

      def to_unstyled_bytes_string_  # #testpoint
        ThroughputMagnetics_::Unstyled_String_via_Throughput_Atom_Stream.new(
          Stream_[ @a ] ).execute
      end

      attr_reader(
        :a,
      )
    end
  end
end
