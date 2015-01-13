module Skylab::Headless

  module System__

    class Services__::Filesystem  # :[#130].

      def initialize system
        @system = system
      end

      def cache
        Filesystem_::Cache__
      end

      def file_utils_controller & p
        if p
          Filesystem_::File_Utils_Controller__.new p
        else
          Filesystem_::File_Utils_Controller__
        end
      end

      def find * x_a
        Filesystem_::Find__.mixed_via_iambic x_a
      end

      def grep * x_a
        Filesystem_::Grep__.mixed_via_iambic x_a
      end

      def hack_guess_module_tree * x_a, & oes_p
        Filesystem_::Hack_guess_module_tree__.call_via_arglist x_a, & oes_p
      end

      def line_stream_via_path path, num_bytes=nil
        Headless_::IO.line_stream ::File.open( path, READ_MODE_ ), num_bytes
      end

      def line_stream_via_pathname pn, num_bytes=nil
        Headless_::IO.line_stream pn.open( READ_MODE_ ), num_bytes
      end

      def members
        self.class.instance_methods false  # neat
      end

      def normalization
        Filesystem_::Normalization__
      end

      def path_tools
        Filesystem_::Path_Tools__
      end

      def tmpdir * x_a
        if x_a.length.zero?
          Filesystem_::Tmpdir__
        else
          Filesystem_::Tmpdir__.new_via_iambic x_a
        end
      end

      def tmpdir_path
        @tmpdir_path ||= tmpdir_pathname.to_path
      end

      def tmpdir_pathname
        @tmpdir_pathname ||= ::Pathname.new Headless_::Library_::Tmpdir.tmpdir
      end

      def walk * x_a
        if x_a.length.zero?
          Filesystem_::Walk__
        else
          Filesystem_::Walk__.call_via_iambic x_a
        end
      end

      Filesystem_ = self

    end
  end
end
