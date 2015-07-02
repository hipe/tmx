module Skylab::Dependency

  class TaskTypes::MkdirP < Home_::Task

    include Home_::Library_::FileUtils

    alias_method :fu_mkdir_p, :mkdir_p
    attribute :dry_run, :boolean => true, :from_context => true, :default => false
    attribute :max_depth, :from_context => true, :default => 1
    attribute :mkdir_p, :required => true
    attribute :verbose, :boolean => true, :from_context => true, :default => true
    listeners_digraph  :all, :info => :all

    def execute args

      @context ||= (args[:context] || {})

      valid? or fail(invalid_reason)

      _n11n = Home_.lib_.system.filesystem.normalization

      did_send_event = nil

      valid_arg = _n11n.existent_directory(
        :path, mkdir_p,
        :is_dry_run, dry_run?,
        :max_mkdirs, max_depth,
        :create_if_not_exist
      ) do | * i_a, & ev_p |
          did_send_event = true
          send :"receive_#{ i_a.last }", ev_p[]
          UNABLE_
        end

      if valid_arg
        valid_arg.value_x
      elsif ! did_send_event
        call_digraph_listeners :info, "directory exists: #{ mkdir_p }"
        valid_arg
      end
    end

    def receive_path_too_deep o
      _msg = "won't mkdir more than #{ o.max_mkdirs } levels deep #{
        }(#{ pretty_path o.path } requires at least #{ o.necessary_mkdirs } levels)"
      call_digraph_listeners :info, _msg
      false
    end

    def receive_file_utils_event o
      call_digraph_listeners :info, "#{ o.message_head }#{ o.path }"
      nil
    end
  end
end
