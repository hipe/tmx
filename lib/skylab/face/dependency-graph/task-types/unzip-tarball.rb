require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::UnzipTarball < Task
      include Open2
      include PathTools
      attribute :unzip_tarball
      def slake
        interpolated? or interpolate! or return false
        slake_deps or return false
        check and return true
        execute
      end
      def check
        if File.directory?(expected_unzipped_dir_path)
          @ui.err.puts("#{hi_name}: ok: is directory: #{expected_unzipped_dir_path}")
          true
        end
      end
      def expected_unzipped_dir_path
        @unzip_tarball.sub(TarballExtension, '')
      end
      def execute
        unless File.exist?(@unzip_tarball)
          @ui.err.puts("#{hi_name}: #{ohno('error:')} tarball not found: #{@unzip_tarball}")
          return false
        end
        cmd = "cd #{escape_path build_dir}; tar -xzvf #{escape_path File.basename(@unzip_tarball)}"
        bytes, seconds = open2(cmd) do |on|
          on.out { |s| @ui.err.write("#{hi_name}: (out): #{s}") }
          on.err { |s| @ui.err.write(s) }
        end
        @ui.err.puts("#{hi_name}: read #{bytes} bytes in #{seconds} seconds.")
        check and return true
        @ui.err.put("#{hi_name}: #{ohno('error: ')}: failed to unzip?")
        false
      end
    end
  end
end
