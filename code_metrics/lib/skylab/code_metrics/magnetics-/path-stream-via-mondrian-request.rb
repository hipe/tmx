module Skylab::CodeMetrics

  class Magnetics_::PathStream_via_MondrianRequest < Common_::Actor::Monadic

    # if any of the paths contain metacharacters that suggest globbing,
    # produce an expanded stream of real file names that accords with the
    # original order of the file globs:
    #
    #
    #     user enters:                           this stream produces:
    #
    #                         +-->           plain/file/one
    #                        /
    #    plain/file/one  -- +    +-->        file-1-from-glob-1/eg/wee
    #                           /
    #    *glob-1/**/wee   -----+---->        file-2-from-glob-1/eg/wee
    #
    #    plain/file/two   -------->          plain/file/two
    #
    #    *glob-2          ---+-->            file-1-from-glob-2
    #                        \
    #                        +--->           file-2-from-glob-2

      def initialize req, & p

        @_listener = p
        @__system_services = req.system_services
        # @head_const = req.head_const
        # @head_path = req.head_path
        @paths = req.paths
        # @require_paths = req.require_paths
      end

      def execute

        is_fnmatch_pattern = nil
        @paths.each_with_index do |path, d|
          if Path_looks_like_pattern___[ path ]
            ( is_fnmatch_pattern ||= [] )[ d ] = true
          end
        end

        if is_fnmatch_pattern
          __when_fnmatch_pattern_offsets is_fnmatch_pattern
        else
          __when_no_fnmatch_patterns
        end
      end

      def __when_no_fnmatch_patterns
        Stream_[ @paths ]
      end

      def __when_fnmatch_pattern_offsets is_fnmatch_pattern

        # in the order that is implied by the user-provided order
        paths = @paths

        _times = paths.length

        _each_offset_st = Common_::Stream.via_times _times

        _each_offset_st.expand_by do |d|

          if is_fnmatch_pattern[ d ]
            __path_stream_via_pattern paths.fetch d
          else
            Common_::Stream.via_item paths.fetch d
          end
        end
      end

      def __path_stream_via_pattern pattern
        _wee = @__system_services.glob pattern
        Stream_[ _wee ]
      end

    # -

    # ==

    fnmatch_pattern_probably_rx = nil
    Path_looks_like_pattern___ = -> path do

      # it is not the case that we can easily parse a string with just a
      # regex to determine if that string contains "metacharacters" in the
      # eyes of (see) `::File.fnmatch`.
      #
      # the naïvest approch is simply to ask:
      #
      #     /[\\*?\[]/ =~ path
      #
      # that is, does the path contain a backslash, an asterisk, a
      # question mark, or an open square bracket? (note we don't check
      # for close because etc.)
      #
      # this simplest approach fails to answer the question, because the
      # `fnmatch` patterns allow for the use of backlashes in the common
      # way. so for example the string:
      #
      #     '\?'
      #
      # (that is, a backslash followed by a question mark) under `fnmatch`
      # matches a literal question mark, and so there are no metacharacters
      # in this pattern, and so our regex gives a false positive against
      # this fnmatch pattern string.
      #
      # so then we might try:
      #
      #     /(?<!\\)[ metacharacters ]/ =~ path
      #
      # which is to say "one of the metacharacters not followed by a
      # backlsash." but this can fail too, because the backslash itself can
      # be escaped. so then we think of:
      #
      #     /(?<!\\(?<!\\))[ metacharacters ]/
      #
      # which is to say, "one of the metacharacters not followed by a
      # backslash that is itself not followed by a backlash." but at this
      # point the futility of our approach becomes clear: as long as we
      # don't have a sense for context from the beginning of the string, we
      # have no way of knowing whether any given first backslash that we
      # match is or isn't itself escaped.
      #
      # to this end we wrote a string-scanner-based function that searched
      # from the beginning of the pattern for any metacharacters and then
      # kept track of backslashes in the appropriate way. but as we did this
      # we realized something: all we were doing was in effect parsing a
      # string for use by `fnmatch`. what would we do differently if for
      # example we had a pattern '\?' vs a pattern '?'? nothing: they are
      # both strings intended for `fnmatch` and it is well out of our scope
      # to determine the meanings of particular expressions within such a
      # string.
      #
      # that's when we realized we were asking the wrong question. the
      # question is not, "is this a string that contains metacharacters
      # in the eyes of `fnmatch`?", but rather, "is this a string intended
      # to be used by `fnmatch`?"
      #
      # and to answer this question, we return blissfully to our original
      # naïveté: does the string contain any of the special characters
      # that `fnmatch` uses? if so, then use `fnmatch`, otherwise not.
      #
      # it is perhaps quite heuristic, but at least it seems infallible:
      # if the (power) user awfully has filenames that contain these
      # special characters, she can write a `fnmatch`-compatible pattern
      # that matches only this path, so no power is lost.
      # :#mon-spot-3

      fnmatch_pattern_probably_rx =~ path
    end

    fnmatch_pattern_probably_rx = Mondrian_[]::FNMATCH_PATTERN_PROBABLY_RX

    # ==
  end
end
# #born for mondrian
