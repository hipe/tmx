module Skylab::Git

  class Magnetics::OneLine_via_Process

    # when you expect exactly one line in response from a request, we'll
    # express failure variously for more than one line, zero lines, any
    # error lines, and a nonzero exitstatus, any of which are treated as
    # abnormal.

    extend ProcLike_

    def initialize prcs, & oes_p
      @listener = oes_p
      @process = prcs
      @_when_no_lines_at_all = :__when_no_lines_at_all_normally
    end

    def on_no_lines_at_all= p
      @_when_no_lines_at_all = :__when_no_lines_at_all_customly
      @__express_no_line_at_all = p
    end

    def execute
      @_line = @process.out.gets
      if @_line
        __when_one_line
      else
        __when_no_lines
      end
    end

    def __when_no_lines

      line = @process.err.gets
      if line
        _common.when_stderr_line line
      else
        send @_when_no_lines_at_all
      end
      UNABLE_
    end

    def __when_no_lines_at_all_customly
      @__express_no_line_at_all[]
      NIL
    end

    def __when_no_lines_at_all_normally
      _common.when_no_stderr_line
      NIL
    end

    def __when_one_line
      line_ = @process.out.gets
      if line_
        self._WHEN_more_than_one_line
      else
        err = @process.err.gets
        if err
          _common.when_stderr_line err  # or not
          UNABLE_
        else
          d = @process.wait.value.exitstatus
          if d.zero?
            @_line
          else
            _common.when_nonzero_exitstatus d
            UNABLE_
          end
        end
      end
    end

    def _common
      Magnetics::Expression_via_Process_that_ProbablyFailed[ @process, & @listener ]
    end
  end
end
# #history: abstracted from one-off
