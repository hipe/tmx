module Skylab::SearchAndReplace

  class Throughput_Magnetics_::Reverse_Throughput_Line_Stream_via_Static_Block

    # providing N number of lines from the end is trivial with a static block.

    def initialize charpos, ltss, big_string
      @big_string = big_string
      @charpos = charpos
      @LTSs = ltss
    end

    def execute

      a = @LTSs

      @_stream = Callback_::Stream.via_range( ( a.length - 1 ) .. 0 ) do |d|
        a.fetch d
      end

      @_current_LTS = @_stream.gets  # assume at least one

      @_state = :__main

      Callback_.stream do  # #[#035]
        send @_state
      end
    end

    def __main

      lts = @_stream.gets
      if lts
        lts_ = remove_instance_variable :@_current_LTS
        cursor_d = lts.end_charpos
        cursor_d_ = lts_.charpos
        a = [ :static_continuing ]
        if cursor_d != cursor_d_
          a.push :content, @big_string[ cursor_d ... cursor_d_ ]
          cursor_d = cursor_d_
        end

        @big_string[ cursor_d ... lts_.end_charpos ] == lts_.string or self._SANITY  # #todo

        a.push :LTS_begin, lts_.string, :LTS_end

        @_current_LTS = lts

        Etc__.new a
      else
        self._B
      end
    end

    # ==

    class Etc__

      def initialize a
        @a = a
      end

      attr_reader(
        :a,
      )
    end
  end
end
