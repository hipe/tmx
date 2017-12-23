module Skylab::Git

  class Magnetics::Commit_via_Path  # 1x in one-off - #not-covered!

    class << self
      def call_by ** h
        new( ** h ).execute
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

      __init_command

      @listener.call :info, :command do
        @_command
      end

      _process = Process_[ * @system.popen3( * @_command ), @_command ]

      o = Magnetics::OneLine_via_Process.new _process, & @listener

      o.on_no_lines_at_all = method :__when_no_lines

      line = o.execute
      if line
        Home_::Models::Commit::Simple.new( * line.split( SPACE_ ), nil )
      else
        line  # unable
      end
    end

    def __init_command
      a = @command_prototype.dup
      a.concat LOG_COMMAND___
      a.push @path
      @_command = a ; nil
    end

    LOG_COMMAND___ = [ 'log', '--follow', '--format=%H %ai', '-1', '--' ].freeze

    def __when_no_lines
      cmd = @_command
      @listener.call :error, :expression do |y|
        y << "can't find commit: expected one, had no lines from ~ #{ cmd * SPACE_ }"
      end
      NIL
    end
  end
end
# #history: abstracted from one-off
