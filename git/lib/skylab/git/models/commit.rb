# frozen_string_literal: true

module Skylab::Git

  module Models::Commit

    class LogStream < Common_::SimpleModel  # [sli]

      # (probably redundant with other guys. make bespoke with fresh thing at #history-A.2)

      def initialize
        yield self

        _cmd = [
          GIT_EXE_,
          'log',
          '--oneline',
          '--abbrev-commit',
        ]

        _processer = remove_instance_variable :@processer

        @_process = _processer.process_via_dir_and_command_tokens(
          remove_instance_variable( :@repository_directory ),
          _cmd,
        )
      end

      attr_writer(
        :repository_directory,
        :processer,
      )

      # --

      def gets_one_commit

        _line = @_process.gets_one_stdout_line
        Simple.new( * THIS_RX___.match( _line ).captures.map( & :freeze ) )
      end

      def CLOSE_EARLY
        remove_instance_variable( :@_process ).CLOSE_EARLY
      end
    end

    # ==

    class Simple

      # (we were expecting maybe to cram some shared string view logic in here)

      def initialize sha, date=nil, time=nil, zone=nil, msg
        @date_string = date
        @SHA_string = sha
        @time_string = time
        @zone_string = zone
        @message_string = msg
        freeze
      end

      attr_reader(
        :date_string,
        :SHA_string,
        :time_string,
        :zone_string,
        :message_string,
      )
    end

    THIS_RX___ = /\A(#{ SHORT_SHA_RXS_ })[ ](.+)\z/

    # ==
    # ==
  end
end
# #history-A.2: injected some stuff
# #history: abstracted from one-off
