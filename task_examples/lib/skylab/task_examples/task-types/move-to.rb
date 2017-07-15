module Skylab::TaskExamples

  class TaskTypes::MoveTo < Common_task_[]

    depends_on_parameters(
      :filesystem,
      :from,
      :move_to,
    )

    def execute
      ok = __from_exists
      ok &&= __to_exists
      ok && ___work
    end

    def ___work

      from = @from ; to = @move_to

      @_listener_.call :info, :expression do |y|
        y << "mv #{ pth from } #{ pth to }"
      end

      d = @filesystem.rename @from, @move_to
      if d.zero?
        ACHIEVED_
      else
        self._COVER_ME
      end
    end

    def __from_exists
      __exists @from
    end

    def __to_exists
      __not_exists @move_to
    end

    def __exists path

      if @filesystem.exist? path
        ACHIEVED_
      else
        __when_not_exist path
      end
    end

    def __not_exists path
      if @filesystem.exist? path
        __when_exist path
      else
        ACHIEVED_
      end
    end

    def __when_not_exist path

      @_listener_.call :error, :expression do |y|
        y << "file not found - #{ pth path }"
      end

      UNABLE_
    end

    def __when_exist path

      @_listener_.call :error, :expression do |y|
        y << "file exists - #{ pth path }"
      end

      UNABLE_
    end
  end
end
# #tombstone: [#005] was where we first did file utils message parsing hacks
