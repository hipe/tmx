require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::TarballTo < Task
      include Open2
      include PathTools
      attribute :tarball_to
      attribute :from
      attribute :get
      def slake
        interpolated? or interpolate! or return false
        if File.exist?(@tarball_to)
          @ui.err.puts "#{hi_name}: exists: #{@tarball_to}"
          return true
        end
        @get.kind_of?(String) or fail("'get' must be string, had: #{get}")
        url = File.join(from, get)
        cmd = "wget -O #{escape_path @tarball_to} #{url}"
        @ui.err.puts "#{blu_name}: executing: #{cmd}"
        bytes, seconds = open2(cmd) do |on|
          on.out { |s| @ui.err.write("#{blu_name}: (out): #{s}") }
          on.err { |s| @ui.err.write(s) }
        end
        @ui.err.puts("#{hi_name}: read #{bytes} bytes in #{seconds} seconds.")
        if File.exist?(@tarball_to)
          @ui.err.puts "#{hi_name}: wrote: #{@tarball_to}"
          return true
        else
          @ui.err.puts "#{hi_name}: failed to write #{@tarball_to} after wget."
          false
        end
      end
      def interpolate_basename
        File.basename(@get)
      end
      def interpolate_stem
        interpolate_basename.sub(TarballExtension, '')
      end
      def blu_name
        style("  #{name}", :cyan)
      end
    end
  end
end
