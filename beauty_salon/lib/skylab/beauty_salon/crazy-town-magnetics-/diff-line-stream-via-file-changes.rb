module Skylab::BeautySalon

  class CrazyTownMagnetics_::DiffLineStream_via_FileChanges < Common_::MagneticBySimpleModel

    # -

      def initialize
        super
      end

      attr_writer(
        :file_changes,
        :listener,
      )

      def execute
        if __zero_file_changes
          __emit_message_about_zero_file
          __result_in_the_empty_stream
        else
          __init_use_these_paths
          __flushie_flushie
        end
      end

      def __flushie_flushie
        Common_::Stream.via_times( @file_changes.count ).expand_by do |d|
          __line_stream_for_file d
        end
      end

      def __line_stream_for_file d

        path = @__use_these_paths.fetch d

        _a = [
          "diff -U a/#{ path } b/#{ path }\n",
          "--- a/#{ path }\n",
          "+++ b/#{ path }\n",
        ]
        hdr_st = Stream_[ _a ]

        p = nil
        transition = -> do
          p = @file_changes.fetch( d ).to_diff_body_line_stream__
          p[]
        end

        p = -> do
          line = hdr_st.gets
          if line
            line
          else
            p = nil
            transition[]
          end
        end

        Common_.stream do
          p[]
        end
      end

      def __init_use_these_paths

        paths = @file_changes.paths

        @__use_these_paths =
        if 1 == @file_changes.count
          paths
        else
          lib = Home_.lib_.basic
          _t = lib::Tree.via :paths, paths
          s_a = _t.longest_common_base_path
          if s_a.length.zero?
            paths
          else
            # information is lost here, fuzzily  - use is on her own to figure out
            _head = s_a.join ::File::SEPARATOR
            localize = lib::Pathname::Localizer[ _head ]
            paths.map do |path|
              localize[ path ]
            end
          end
        end
        NIL
      end

      def __zero_file_changes
        @file_changes.count.zero?
      end

      def __result_in_the_empty_stream
        Skylab::Common::THE_EMPTY_STREAM
      end

      def __emit_message_about_zero_file
        @listener.call :info, :expression do |y|
          y << "(no results.)"
        end
      end
    # -

    # ==

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end

    # ==
    # ==
  end
end
# #born.
