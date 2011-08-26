require File.expand_path('../../task', __FILE__)
module Skylab::Face
  class DependencyGraph
    class TaskTypes::ExecutableFile < Task
      attribute :executable_file
      def slake
        interpolated? or interpolate! or return false
        if File.exist?(@executable_file)
          execute
        elsif deps?
          slake_deps and execute
        else
          dead_end
        end
      end
    protected
      def execute
        stat = File::Stat.new(@executable_file)
        if stat.executable?
          @ui.err.puts("#{hi_name}: ok, executable: #{@executable_file}")
          true
        else
          @ui.err.puts("#{hi_name}: #{ohno('error:')} exists but is not executable: #{@executable_file}.")
          false
        end
      end
    end
  end
end
