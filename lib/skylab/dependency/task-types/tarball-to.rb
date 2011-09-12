require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::TarballTo < Task
      include Open2
      include PathTools
      attribute :tarball_to
      attribute :from, :required => false
      attribute :get
      attribute :stem, :required => false
      def slake
        interpolated? or interpolate! or return false
        check_exists_nonzero and return true
        @get.kind_of?(String) or _fail("'get' must be string, had: #{get}")
        url = @from ? File.join(from, get) : get
        # cmd = "wget -O #{escape_path @tarball_to} #{url}"
        cmd = "curl -OL h #{url} > #{escape_path @tarball_to}"
        @ui.err.puts "#{blu_name}: executing: #{cmd}"
        bytes, seconds = open2(cmd) do |on|
          on.out { |s| @ui.err.write("#{blu_name}: (out): #{s}") }
          on.err { |s| @ui.err.write(s) }
        end
        @ui.err.puts("#{me}: read #{bytes} bytes in #{seconds} seconds.")
        wrap_up
      end
      def wrap_up
        case bytes = self.bytes(@tarball_to)
        when nil
          @ui.err.puts "#{me}: failed to write #{@tarball_to} after curl."
          false
        when 0
          @ui.err.puts "#{me}: strange, wrote zero bytes: #{@tarball_to} (0 bytes)"
          false
        else
          @ui.err.puts "#{me}: wrote: #{@tarball_to}"
          true
        end
      end
      def check_exists_nonzero
        case (bytes = self.bytes(@tarball_to))
        when nil
          false
        when 0
          @ui.err.puts "#{me}: strange, had zero byte file (#{@tarball_to}). Will overwrite."
          false
        else
          @ui.err.puts "#{me}: exists: #{@tarball_to} (#{bytes} bytes)"
          true
        end
      end
      def bytes path
        if File.exist?(path)
          File.stat(path).size
        else
          nil
        end
      end
      def interpolate_basename
        File.basename(@get)
      end
      def interpolate_stem
        @stem || interpolate_basename.sub(TarballExtension, '')
      end
      def blu_name
        style("  #{name}", :cyan)
      end
    end
  end
end
