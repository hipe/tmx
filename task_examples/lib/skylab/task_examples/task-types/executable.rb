module Skylab::TaskExamples

  class TaskTypes::Executable < Common_task_[]

    # succeeds if the given executable name is in the system's PATH
    # environment variable. reports its findings either way.

    depends_on_parameters(
      :executable,
    )

    def execute

      path = Home_.lib_.system.open2 [ 'which', @executable ]  # ??

      path.strip!  # necessary IFF nonzero length
      if path.length.zero?
        ___when_not_in_PATH
      else
        __when_in_PATH path
      end
    end

    def ___when_not_in_PATH
      x = @executable
      @_listener_.call :error, :expression do |y|
        y << "not in PATH: #{ x }"
      end
      UNABLE_
    end

    def __when_in_PATH path
      @_listener_.call :info, :expression do |y|
        y << "#{ path }"
      end
      ACHIEVED_
    end
  end
end
