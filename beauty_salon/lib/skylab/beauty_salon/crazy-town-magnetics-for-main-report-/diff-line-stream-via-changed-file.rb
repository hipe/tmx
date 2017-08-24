# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagneticsForMainReport_::DiffLineStream_via_ChangedFile < Common_::MagneticBySimpleModel

    # given the real file's path and the changed file in a *tmpfile*,
    # produce a stream of diff lines but alter the first few lines of
    # it so it looks like a `git`-style diff that refers to only the
    # file and makes no mention of the tmpfile.

    # (this magnetic has "stream" in its result name because we love
    # streams, but in fact its name is more conceptual than literal.
    #
    # but keep in mind any tmpfile can be turnd into a stream by:
    #   1) move the the tmpfile to some semi-permanent location
    #   2) open the file and lock it (now)
    #   3) when the last line of the file is delivered, delete the file.
    # )

    # -

      attr_writer(
        :changed_file_IO,
        :line_yielder,
        :listener,
        :source_buffer,
      )

      def execute
        if __resolve_line_stream
          __flush_to_line_yielder
        end
      end

      def __flush_to_line_yielder
        st = remove_instance_variable :@__use_line_stream
        d = 0
        y = remove_instance_variable :@line_yielder
        while line=st.gets
          d += line.length
          y << line
        end
        d
      end

      def __resolve_line_stream
        _ = __flush_to_line_stream
        _store :@__use_line_stream, _
      end

      def __flush_to_line_stream

        ok = __resolve_real_diff_line_stream
        ok &&= __check_and_skip_first_line_of_real_diff
        ok &&= __check_and_skip_second_line_of_real_diff
        ok && __do_flush_to_line_stream
      end

      def __do_flush_to_line_stream

        path = _before_path

        a_path = ::File.join 'a', path
        b_path = ::File.join 'b', path

        _first_three_lines = [
          "diff -U #{ a_path } #{ b_path }",
          "--- #{ a_path }",
          "+++ #{ b_path }",
        ]

        first_three_lines_scn = Common_::Scanner.via_array _first_three_lines
        real_diff_line_stream = nil

        p = nil ; main = nil

        p = -> do
          if first_three_lines_scn.no_unparsed_exists
            first_three_lines_scn = nil
            real_diff_line_stream = remove_instance_variable :@_real_diff_line_stream
            ( p = main )[]
          else
            _hi = first_three_lines_scn.gets_one
            _hi  # hi. #todo
          end
        end

        main = -> do
          _line = real_diff_line_stream.gets
          _line  # hi. #todo
        end

        Common_.stream do
          p[]
        end
      end

      def __resolve_first_line_of_real_diff

        _line = @_real_diff_line_stream.gets

        _store :@__first_line_of_real_diff, _line
      end

      # --

      def __check_and_skip_first_line_of_real_diff
        _next_line_must_be_this %r(\A---[ ][^[:space:]])
      end

      def __check_and_skip_second_line_of_real_diff
        _next_line_must_be_this %r(\A\+\+\+[ ][^[:space:]])
      end

      def _next_line_must_be_this rx
        line = @_real_diff_line_stream.gets
        if line
          if rx =~ line
            ACHIEVED_
          else
            self._COVER_ME__diff_line_did_not_match_expected_pattern__
          end
        else
          self._COVER_ME__real_diff_stream_ended_early__
        end
      end

      # --

      def __resolve_real_diff_line_stream

        _before_path = self._before_path
        _after_path = @changed_file_IO.path

        _ = Home_.lib_.system.diff.by do |o|
          o.do_result_in_line_stream = true
          o.left_file_path = _before_path
          o.right_file_path = _after_path
        end

        _store :@_real_diff_line_stream, _
      end

      # --

      def _before_path
        @source_buffer.name
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==
    # ==
  end
end
# #history-A.2: full rewrite to use real diff and whatever
# #tombstone-A.1: get rid of path shortener. make this one-to-one with files. no longer stream-based (but could be)
# #born.
