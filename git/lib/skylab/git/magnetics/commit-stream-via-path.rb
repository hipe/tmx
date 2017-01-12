module Skylab::Git

  class Magnetics::CommitStream_via_Path

    class << self
      def for rsx
        new( rsx.path, rsx.command_prototype, rsx.system, & rsx.listener ).execute
      end
      private :new
    end  # >>

    def initialize path, cmd_proto, system, & p
      @command_prototype = cmd_proto
      @path = path
      @system = system
      @_on_event_selectively = p
    end

    def execute
      cmd = remove_instance_variable( :@command_prototype ).dup
      cmd.concat COMMAND_BODY___
      cmd.push @path

      @_on_event_selectively.call( :info, :command ) { cmd }

      _a = * remove_instance_variable( :@system ).popen3( * cmd )
      @_process = Process_[ * _a, cmd ]

      @_method = :__first_gets
      Common_.stream do
        send @_method
      end
    end

    COMMAND_BODY___ = [ 'log', '--follow', '--format=%H %ai', '--' ]

    def __first_gets
      @_line = @_process.out.gets
      if @_line
        @_method = :__subsequent_gets
        _item_via_line
      else
        line = @_process.err.gets
        if line
          _when_err_line line
        else
          __when_no_err_line
        end
      end
    end

    def __when_no_err_line
      path = @path
      @_on_event_selectively.call :error, :expression do |y|
        y << "found no commits for `#{ path }` - does the file exist?"
      end
      UNABLE_
    end

    def __subsequent_gets
      @_line = @_process.out.gets
      if @_line
        _item_via_line
      else
        remove_instance_variable :@_method  # or etc
        line = @_process.err.gets
        if line
          _when_err_line line
        else
          NOTHING_
        end
      end
    end

    def _when_err_line line
      _o = Magnetics::Expression_via_Process_that_ProbablyFailed.new(
        @_process, & @_on_event_selectively )
      _o.when_stderr_line line
      UNABLE_
    end

    def _item_via_line
      @_line.chomp!
      _a = remove_instance_variable( :@_line ).split SPACE_
      Home_::Models::Commit::Simple.new( * _a )
    end
  end
end
