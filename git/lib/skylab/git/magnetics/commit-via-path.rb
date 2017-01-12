module Skylab::Git

  class Magnetics::Commit_via_Path

    class << self
      def call * a, & p
        new( * a, & p ).execute
      end
      alias_method :[], :call
      private :new
    end

    def initialize path, cmd_proto, sys, & oes_p
      @command_prototype = cmd_proto
      @path = path
      @system = sys
      @listener = oes_p
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
        Home_::Models::Commit::Simple.new( * line.split( SPACE_ ) )
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
