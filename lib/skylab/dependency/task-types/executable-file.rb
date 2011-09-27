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
          _info "not installed, executable not found: #{@executable_file}."
          false
        end
      end
    protected
      def execute
        stat = File::Stat.new(@executable_file)
        if stat.executable?
          _info "ok, executable: #{@executable_file}"
        else
          _err "exists but is not executable: #{@executable_file}."
        end
      end
    end
  end
end

