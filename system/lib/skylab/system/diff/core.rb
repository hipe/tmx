module Skylab::System

  class Diff

    # :[#023.1]:
    #
    #   - in antiquity this did something in [tm], and has since
    #     been fully rewritten.
    #
    #   - see the closely related (but now older) [#023.2] "patch"

    class Service

      def initialize svcs  # when the service is built, assume we will money

        _fs = svcs.filesystem

        _path = ::File.join svcs.defaults.dev_tmpdir_path, '[sy]'

        _tfs = Home_::Filesystem::TmpfileSessioner.define do |o|

          o.tmpdir_path _path

          o.create_at_most_N_directories 2  # etc

          o.using_filesystem _fs
        end

        @__tmpfile_sessioner = _tfs
      end

      def by
        Diff_via___.call_by do |o|
          yield o
          o.tmpfile_sessioner = @__tmpfile_sessioner
        end
      end
    end

    # ==

    class Diff_via___ < Common_::MagneticBySimpleModel

      def initialize
        super  # hi.
      end

      def left_line_stream= st
        @_lease_left_path = :__lease_left_path_via_line_stream
        @__left_path_line_stream = st
      end

      def right_line_stream= st
        @_lease_right_path = :__lease_right_path_via_line_stream
        @__right_path_line_stream = st
      end

      attr_writer(
        :tmpfile_sessioner,
      )

      def left_file_path= path
        @_lease_left_path = :__lease_left_path_via_file_path
        @__left_file_path = path
      end

      def right_file_path= path
        @_lease_right_path = :__lease_right_path_via_file_path
        @__right_file_path = path
      end

      def execute

        _lease_two_paths do |left_path, right_path|
          @_left_path = left_path
          @_right_path = right_path
          __work
        end
      end

      def __work
        _process = __build_process
        _hunk_st = Here_::Magnetics::HunkStream_via_FileDiffProcess[ _process ]
        Here_::Magnetics::Diff_via_HunkStream[ _hunk_st ]
      end

      def __build_process

        read_out, write_out = ::IO.pipe
        read_err, write_err = ::IO.pipe

        cmd = [ * DIFF_COMMAND_HEAD__, @_left_path, @_right_path ]

        pid = ::Kernel.spawn(
          * cmd,
          err: write_err,
          out: write_out,
        )

        write_out.close
        write_err.close

        _process = Basic_[]::Process.define do |o|
          o.out = read_out
          o.err = read_err
          o.pid = pid
        end
        _process  # hi.
      end

      DIFF_COMMAND_HEAD__ = %w( diff --unified )  # ..

      def _lease_two_paths
        send( @_lease_left_path ) do |left_path|
          send( @_lease_right_path ) do |right_path|
            yield left_path, right_path
          end
        end
      end

      def __lease_left_path_via_file_path
        yield remove_instance_variable :@__left_file_path
      end

      def __lease_right_path_via_file_path
        yield remove_instance_variable :@__right_file_path
      end

      def __lease_left_path_via_line_stream & p
        _st = remove_instance_variable :@__left_path_line_stream
        _lease_path_via_line_stream _st, & p
      end

      def __lease_right_path_via_line_stream & p
        _st = remove_instance_variable :@__right_path_line_stream
        _lease_path_via_line_stream _st, & p
      end

      def _lease_path_via_line_stream st

        @tmpfile_sessioner.session do |io|
          while line = st.gets
            io.puts line
          end
          io.rewind
          yield io.path
        end
      end
    end

    # ==

    Here_ = self
  end
end
# #history: full rewrite from some ancient thing in [tm] that just counted lines
