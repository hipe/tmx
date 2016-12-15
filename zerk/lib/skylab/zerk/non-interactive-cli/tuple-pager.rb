module Skylab::Zerk

  class NonInteractiveCLI

    class TuplePager  # :[#047]. 3 laws. a better version of [#br-064]

      # #open [#058] someone is looking for you

      # the subject is given a list of tuples in the form of one item
      # (representing the first item in the list) and a stream holding the
      # remaining zero or more items. (the interface is like this for the
      # conveninece of clients, but a corollary of it is that we are
      # guaranteed to have a collection of at least one item.)
      #
      # each tuple is (for now) a struct, and each item is assumed to be a
      # struct with the same structure as the first (in terms of its members
      # and in terms of their order).
      #
      # currently it is assumed that each instance member of each struct is
      # a string. the onus is on the client to convert non-strings to string
      # representation and populate nil fields with the empty string.
      #
      # as happens in four or five [#tab-001] previous table implementations,
      # the tuples are traversed in a double-pass so that each column's width
      # is determined by the widest string in that column. but UNLIKE any of
      # those, we avoid assuming that there's infinite memory by placing a
      # cap on how many rows are cached before being flushed. this is the
      # `page_size`, which is the maximum number of lines that will go into
      # the cache before being flushed.
      #
      # the effect of this is that maybe sometimes (but not necessarily always
      # or even ever, depending on the data) there is a "break" in formatting
      # where one or more columns suddenly get wider. this is a tradeoff so
      # that the rendering agent doesn't need to consume the memory required
      # to swallow all of the data before displaying it.
      #
      # presently in each next "page" the widths of columns is not cleared,
      # so in effect each next page can only make the columns go wider. they
      # never shrink back down.
      #
      # ## options
      #
      # a header row can be (currently always is) inferred from the members of the first struct
      # and emitted. such a leading row is handled and expresed exactly as
      # the data tuples are.
      #
      # ## considerations & caveats
      #
      # presently there is NO facility for a "max width" that a column can
      # stretch to (it is always determined solely by the data) so this might
      # not look good for datasets the width of whose data cels varies "widely".

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @do_show_header = true
      end

      attr_writer(
        :first_tuple,
        :left_glyph,
        :page_size,
        :right_glyph,
        :separator_glyph,
        :tuple_stream,
      )

      def execute
        @left_glyph ||= LEFT_GLYPH___
        @page_size ||= 80
        @right_glyph ||= RIGHT_GLYPH___
        @separator_glyph ||= SEPARATOR_GLYPH___

        @_m = :__the_very_first_line

        Common_.stream do
          send @_m
        end
      end

      def __the_very_first_line

        @_found_the_end = false
        a = @first_tuple.members
        @_num_cols = a.length
        @_tuple_cache = []
        @_widths = @_num_cols.times.map{ 0 }.to_a

        @_countdown = @page_size

        if @do_show_header
          _s_a = @first_tuple.members.map( & :id2name )
          _index_and_cache_tuple _s_a
        end

        if @_countdown.zero?
          self._ANNOYING_cover_me
        end
        _swallow_page
        send @_m
      end

      def _gets_from_tuple_cache_stream

        tu = @_tuple_cache_stream.gets
        if tu
          @_format % tu.to_a
        else
          __maybe_next_page
        end
      end

      def __maybe_next_page  # result in a line or false-ish

        tu = if @_found_the_end
          @_user_falseish
        else
          tu = @tuple_stream.gets
        end
        if tu
          @first_tuple = tu
          @_in_use.clear
          @_tuple_cache = remove_instance_variable :@_in_use
          @_countdown = @page_size
          _swallow_page
          send @_m
        else
          remove_instance_variable :@_m  # or nothing
          tu
        end
      end

      def _swallow_page   # must set @_m

        _index_and_cache_tuple remove_instance_variable :@first_tuple

        st = @tuple_stream
        begin
          if @_countdown.zero?
            break
          end
          tu = st.gets
          if ! tu
            @_user_falseish = tu
            @_found_the_end = true
            break
          end
          _index_and_cache_tuple tu
          redo
        end while nil

        @_in_use = remove_instance_variable :@_tuple_cache  # or not
        @_tuple_cache_stream = Common_::Stream.via_nonsparse_array @_in_use

        __reinit_format_string

        @_m = :_gets_from_tuple_cache_stream
        NIL
      end

      def _index_and_cache_tuple tuple
        @_num_cols.times do |col_d|
          d = tuple[ col_d ].length
          if d > @_widths[ col_d ]
            @_widths[ col_d ] = d
          end
        end
        @_tuple_cache.push tuple
        @_countdown -= 1
        NIL
      end

      def __reinit_format_string
        st = Common_::Stream.via_times @_num_cols do |d|
          "%#{ @_widths.fetch d }s"
        end
        buffer = @left_glyph.dup
        buffer << st.gets
        begin
          s = st.gets
          s || break
          buffer << @separator_glyph << s
          redo
        end while nil
        buffer << @right_glyph
        @_format = buffer ; nil
      end

      LEFT_GLYPH___ = "| "
      RIGHT_GLYPH___ = " |\n"
      SEPARATOR_GLYPH___ = " | "
    end
  end
end
