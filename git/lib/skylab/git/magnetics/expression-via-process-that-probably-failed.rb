module Skylab::Git

  class Magnetics::Expression_via_Process_that_ProbablyFailed

    extend ProcLike_

    def initialize pcs, & p
      @_command = pcs.command
      @_serr = pcs.err
      @_wait = pcs.wait
      @_on_event_selectively = p
    end

    def execute
      line = @_serr.gets
      if line
        when_stderr_line line
      else
        when_no_stderr_line
      end
    end

    def when_stderr_line line

      did = false
      es_p = -> do
        did = true
        _init_exitstatus
        @_exitstatus
      end

      cmd = @_command ; serr = @_serr

      @_on_event_selectively.call :error, :expression do |y|
        y << "couldn't execute command ~ #{ cmd.join SPACE_ }"
        begin
          line_ = serr.gets
          line_ || break
          y << "  >> #{ line }"
          line = line_
          redo
        end while above
        line.chomp!
        y << "  >> #{ line } (exitstatus: #{ es_p[] })"
      end

      did || _init_exitstatus  # the above emission may have been ignored
      _maybe_express_exitstatus
      NIL
    end

    def when_no_stderr_line
      cmd = @_command
      _init_exitstatus
      es = @_exitstatus
      @_on_event_selectively.call :error, :expression do |y|
        y << "couldn't execute command ~ #{ cmd.join SPACE_ }"
        y << "(exitstatus: #{ es })"
      end
      _maybe_express_exitstatus
      NIL
    end

    def _init_exitstatus
      @_exitstatus = remove_instance_variable( :@_wait ).value.exitstatus ; nil
    end

    def _maybe_express_exitstatus
      es = @_exitstatus
      if es.nonzero?
        when_nonzero_exitstatus es
      end
      NIL
    end

    def when_nonzero_exitstatus es
      @_on_event_selectively.call( :error, :nonzero_exitstatus ) { es }
      NIL
    end
  end
end
