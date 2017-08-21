module Skylab::BeautySalon

  class CrazyTownMagneticsForMainReport_::DiffLineStream_via_FileChanges < Common_::MagneticBySimpleModel

    # -

      attr_writer(
        :file_changes,
        :line_yielder,
        :listener,
      )

      def execute

        __write_header_lines @file_changes.path
        __write_the_rest

        @line_yielder
      end

      def __write_the_rest
        st = @file_changes.to_diff_body_line_stream__
        while (line = st.gets)
          @line_yielder << line
        end
      end

      def __write_header_lines path

        _a = [
          "diff -U a/#{ path } b/#{ path }",
          "--- a/#{ path }",
          "+++ b/#{ path }",
        ]
        _a.each do |line|
          @line_yielder << line
        end
      end
    # -

    # ==
    # ==
  end
end
# #tombstone-A.1: get rid of path shortener. make this one-to-one with files. no longer stream-based (but could be)
# #born.
