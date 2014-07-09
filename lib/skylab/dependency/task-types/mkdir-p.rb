module Skylab::Dependency
  class TaskTypes::MkdirP < Dep_::Task
    include Dep_::Library_::FileUtils
    alias_method :fu_mkdir_p, :mkdir_p
    attribute :dry_run, :boolean => true, :from_context => true, :default => false
    attribute :max_depth, :from_context => true, :default => 1
    attribute :mkdir_p, :required => true
    attribute :verbose, :boolean => true, :from_context => true, :default => true
    listeners_digraph  :all, :info => :all
    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      if ::File.directory?(dir = ::Pathname.new(mkdir_p))
        call_digraph_listeners :info, "directory exists: #{dir}"
        return true
      end
      current_depth = 0
      max_depth = self.max_depth
      begin
        dir = dir.dirname
        current_depth += 1
      end while ! dir.directory? and ! %w(. /).include?(dir.to_s) and current_depth <= max_depth
      if current_depth > max_depth
        call_digraph_listeners(:info, "won't mkdir more than #{max_depth} levels deep " <<
          "(#{pretty_path mkdir_p} requires at least #{current_depth} levels)"
        )
        return false
      end
      fu_mkdir_p mkdir_p, :noop => dry_run?, :verbose => verbose?
      true
    end
    def fu_output_message msg
      call_digraph_listeners :info, msg
    end
  end
end
