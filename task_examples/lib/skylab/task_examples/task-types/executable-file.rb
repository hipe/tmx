module Skylab::TaskExamples
  class TaskTypes::ExecutableFile < Home_::Task
    attribute :executable_file, :required => true, :pathname => true
    listeners_digraph  :all, :info => :all

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      # used to have @inrequisite
      if ! @executable_file.exist?
        call_digraph_listeners(:info, "executable does not exist: #{@executable_file}")
        return false
      end
      stat = ::File::Stat.new @executable_file.to_s
      if stat.executable?
        call_digraph_listeners(:info, "ok, executable: #{@executable_file}")
        true
      else
        call_digraph_listeners(:info, "exists but is not executable: #{@executable_file}.")
        false
      end
    end
  end
end
