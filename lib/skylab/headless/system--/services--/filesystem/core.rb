module Skylab::Headless

  module System__

    class Services__::Filesystem

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

      def line_scanner_via_path path, num_bytes=nil
        Headless_::IO.line_scanner ::File.open( path, READ_MODE_ ), num_bytes
      end

      def line_scanner_via_pathname pn, num_bytes=nil
        Headless_::IO.line_scanner pn.open( READ_MODE_ ), num_bytes
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
          Filesystem_::Tmpdir__.build_via_iambic x_a
        end
      end

      def tmpdir_path
        @tmpdir_path ||= tmpdir_pathname.to_path
      end

      def tmpdir_pathname
        @tmpdir_pathname ||= ::Pathname.new Headless_::Library_::Tmpdir.tmpdir
      end

      Filesystem_ = self
    end
  end
end
