require File.expand_path('../../task', __FILE__)

module Skylab
  module Dependency
    class TaskTypes::ExecutableFile < Task
      attribute :executable_file
      def slake
        if File.exist?(@executable_file)
          execute
        elsif fallback?
          fallback.slake and execute
        else
          dead_end
        end
      end
      def check
        if File.exist?(@executable_file)
          execute
        else
          ui.err.puts("#{me}: not installed, executable not found: #{@executable_file}.")
          false
        end
      end
    protected
      def execute
        stat = File::Stat.new(@executable_file)
        if stat.executable?
          ui.err.puts("#{me}: ok, executable: #{@executable_file}")
          true
        else
          ui.err.puts("#{me}: #{ohno('error:')} exists but is not executable: #{@executable_file}.")
          false
        end
      end
    end
  end
end
