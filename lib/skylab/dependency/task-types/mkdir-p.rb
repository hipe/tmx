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

      did_send_event = nil

      kn = Home_.lib_.system.filesystem( :Existent_Directory ).with(
        :path, mkdir_p,
        :is_dry_run, dry_run?,
        :max_mkdirs, max_depth,
        :create_if_not_exist

      ) do | * i_a, & ev_p |
          did_send_event = true
          send :"receive_#{ i_a.last }", ev_p[]
          UNABLE_
        end

      if kn
        kn.value_x
      elsif ! did_send_event
        call_digraph_listeners :info, "directory exists: #{ mkdir_p }"
        kn
      end
    end

    def receive_path_too_deep o

      _msg = "won't mkdir more than #{ o.max_mkdirs } levels deep #{
        }(#{ pretty_path o.path } requires at least #{ o.necessary_mkdirs } levels)"

      call_digraph_listeners :info, _msg

      UNABLE_
    end

    def receive_creating_directory o

      call_digraph_listeners :info, "mkdir #{ o.path }"

      NIL_
    end
  end
end
