# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::Buffers_via_Downstream_and_Upstream_Buffer

    # this would be very normal and straightforward were it not for the
    # massive hack we're attempting to write heredocs.
    #
    # heredocs have a dedicated location class. they have a strange
    # syntax that breaks all our normal techniques: heredocs are perhaps
    # the only construct where the placement of some of its elements
    # "hops out" of the boundaries of the feature (in effect).
    #
    # consider the three parts of an idealized heredoc feature:
    #   1) `<<-HERE`, 2) some lines 3) `HERE` (the closing one)
    #
    # these three parts together express a literal string. but if try
    # to treat this like a quoted string (with the `<<-HERE` like an
    # open quote and the `HERE` like a close quote) it will cause you
    # some gotchas, depending on whether you're doing weird things.
    #
    # syntactically, it's as if the `<<-HERE` expression itself is the
    # *entire* literal string..
    #
    # :#spot1.4

    # -
      def initialize d, down, up
        @pos = d
        @downstream_buffer = down
        @upstream_buffer = up

        @_big_flip_OK = true
        _methods_be_normal
      end

      def BIG_FLIP r, & p
        remove_instance_variable :@_big_flip_OK
        @_heredoc_end_range = r
        @_then_do_this = p
        @_write_range = :__write_range_CRAZILY
        @_concat = :__concat_CRAZILY
      end

      # ~

      def recurse_into_listlike context_by=nil, listlike
        listlike.length.times do |d|
          _sn = listlike.dereference d
          recurse_into_structured_node context_by, _sn
        end
        NIL
      end

      def recurse_into_structured_node context_by=nil, sn

        d = Home_::CrazyTownReportMagnetics_::String_via_StructuredNode::Recurse.call_by do |o|
          o.context_by = context_by
          o.structured_node = sn
          o.buffers = self
        end

        if d.zero?  # #here4
          NOTHING_  # #coverpoint5.2
        end
      end

      # ~

      def write s, end_d
        self << s
        be_at_offset end_d
      end

      def write_as_is_to_here end_d
        beg_d = @pos
        case beg_d <=> end_d
        when -1
          send @_write_range, beg_d...end_d
        when 0 ; NOTHING_
        else ; oops
        end
      end

      def << s
        send @_concat, s
      end

      # ~

      def __write_range_CRAZILY r
        # in crazy mode, you're monitoring the incoming ranges for one with
        # a newline. if no newline, write as normal. but on first newline,..
        s = _string_via_range r
        d = s.index NEWLINE_
        if d
          __crazy_time d, s, r
        else
          _do_write_range r.end, s
        end
      end

      def __crazy_time local_d, s, r

        # when you find the first newline, it's time to flush the body of
        # the heredoc and then resume to normal mode.

        if local_d.nonzero?
          self._README__no_problem__
          # if the newline was not at the beginning of the string ..
          # make sure we don't skip anything we shouldn't
        end

        end_r = remove_instance_variable :@_heredoc_end_range

        if ! r.include? end_r.begin_pos
          self._COVER_ME__no_problem__
        end

        # reminder: the cursor is pointing at the newline that ends part (1).

        _methods_be_normal
        remove_instance_variable( :@_then_do_this ).call

        if end_r.begin_pos != @pos
          self._COVER_ME__no_problem__
        end

        _write_range_normally end_r.begin_pos...end_r.end_pos

        @_big_flip_OK = true ; nil
      end

      def _methods_be_normal
        @_write_range = :_write_range_normally
        @_concat = :_concat
      end

      def __concat_CRAZILY s
        s.include? NEWLINE_ and self._COVER_ME__no_problem__
        _concat s
      end

      # ~

      def _write_range_normally r
        _s = _string_via_range r
        _do_write_range r.end, _s
      end

      def _do_write_range end_pos, s
        _concat s
        be_at_offset end_pos
      end

      def _string_via_range r
        @upstream_buffer[ r ]
      end

      def _concat s
        @downstream_buffer << s ; nil
      end

      def be_at_offset d
        @pos = d ; nil
      end

      def [] * a
        @upstream_buffer[ * a ]
      end

      attr_reader(
        :pos,
        :upstream_buffer,
        :downstream_buffer,
      )

      alias_method :_DS, :downstream_buffer
    # -
  end
end
# #abstracted.
