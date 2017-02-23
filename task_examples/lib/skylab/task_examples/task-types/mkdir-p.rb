module Skylab::TaskExamples

  class TaskTypes::MkdirP < Common_task_[]

    depends_on_parameters(

      dry_run: [ :flag, :default, false ],

      max_depth: [ :default, 1 ],

      mkdir_p: nil,

      verbose: [ :flag, :default, true, ],
    )

    def execute

      did_send_event = nil

      kn = Home_.lib_.system.filesystem( :Existent_Directory ).call_via(
        :path, @mkdir_p,
        :is_dry_run, @dry_run,
        :max_mkdirs, @max_depth,
        :create_if_not_exist,

      ) do | * i_a, & ev_p |
        did_send_event = true
        send :"__on__#{ i_a.last }__", ev_p[]
      end

      if kn
        @created_directory = kn.value_x
        ACHIEVED_
      else
        remove_instance_variable :@_result
      end
    end

    def __on__path_too_deep__ ev

      @_result = UNABLE_

      @_oes_p_.call :error, :path_too_deep do
        ev
      end
      UNRELIABLE_
    end

    def _WASABOVE

      _msg = "won't mkdir more than #{ ev.max_mkdirs } levels deep #{
        }(#{ pretty_path ev.path } requires at least #{ ev.necessary_mkdirs } levels)"

      call_digraph_listeners :info, _msg

      NIL_
    end

    def __on__creating_directory__ ev

      @_oes_p_.call :info, :creating_directory do
        ev
      end
      UNRELIABLE_
    end

    attr_reader(
      :created_directory,
    )
  end
end
