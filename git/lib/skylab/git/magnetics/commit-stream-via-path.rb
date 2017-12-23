module Skylab::Git

  class Magnetics::CommitStream_via_Path  # 1x in one-off - #not-covered!

    class << self
      def call_by ** hh
        new( ** hh ).execute
      end
      private :new
    end  # >>

    def initialize(
      path: nil,
      command_prototype: nil,
      system: nil,
      listener: nil
    )
      @path = path
      @command_prototype = command_prototype
      @system = system
      @listener = listener
    end

    def execute
      cmd = remove_instance_variable( :@command_prototype ).dup
      cmd.concat COMMAND_BODY___
      cmd.push @path

      @listener.call( :info, :command ) { cmd }

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
      @listener.call :error, :expression do |y|
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
        @_process, & @listener )
      _o.when_stderr_line line
      UNABLE_
    end

    def _item_via_line
      @_line.chomp!
      _a = remove_instance_variable( :@_line ).split SPACE_
      Home_::Models::Commit::Simple.new( * _a, nil )
    end
  end
end
# #history-A.1: converted to use named arguments in construction
