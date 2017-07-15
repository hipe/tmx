module Skylab::TaskExamples

  class TaskTypes::ExecutableFile < Common_task_[]

    # in contrast to the similarly named "executable" task, this succeeds
    # IFF the given path is executable according to the filesystem.

    depends_on_parameters(
      :executable_file,
      :filesystem,
    )

    def execute

      begin
        stat = @filesystem.stat @executable_file
      rescue ::Errno::ENOENT => e
      end

      if stat
        __when_exist stat
      else
        ___when_no_such_file e
      end
    end

    def ___when_no_such_file e

      _eek_message = /\A(?:(?! @).)+/.match( e.message )[ 0 ]
      path = @executable_file

      @_listener_.call :error, :expression do |y|
        y << "#{ _eek_message } - #{ pth path }"
      end
      UNABLE_
    end

    def __when_exist stat

      if stat.executable?
        __when_executable
      else
        ___when_not_executable
      end
    end

    def __when_executable

      path = @executable_file
      @_listener_.call :info, :expression do |y|
        y << "ok, executable - #{ pth path }"
      end
      ACHIEVED_
    end

    def ___when_not_executable

      path = @executable_file
      @_listener_.call :error, :expression do |y|
        y << "exists but is not executable - #{ pth path }"
      end
      UNABLE_
    end
  end
end
