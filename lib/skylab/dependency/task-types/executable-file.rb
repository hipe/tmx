module Skylab::Dependency
  class TaskTypes::ExecutableFile < Dependency::Task
    attribute :executable_file, :required => true, :pathname => true
    emits :all, :info => :all

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      # used to have @inrequisite
      if ! @executable_file.exist?
        emit(:info, "executable does not exist: #{@executable_file}")
        return false
      end
      stat = ::File::Stat.new @executable_file.to_s
      if stat.executable?
        emit(:info, "ok, executable: #{@executable_file}")
        true
      else
        emit(:info, "exists but is not executable: #{@executable_file}.")
        false
      end
    end
  end
end
