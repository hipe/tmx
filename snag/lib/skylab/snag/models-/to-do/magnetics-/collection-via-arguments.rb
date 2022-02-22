module Skylab::Snag

  class Models_::ToDo

    class Magnetics_::Collection_via_Arguments < Common_::SimpleModel

      def initialize
        yield self
      end

      attr_writer(
        :filename_patterns,
        :listener,
        :paths,
        :patterns,
        :system_conduit,
      )

      def to_stream

        cmd = build_system_command
        cmd and begin

          @command = cmd

          p = @listener

          st = Magnetics_::MatchingLineStream_via_FindCommand.call(
            cmd, @system_conduit, & p )

          st and begin

            Magnetics_::ToDoStream_via_MatchingLineStream.call(
              st, @patterns, & p )
          end
        end
      end

      attr_reader :command

      def build_system_command
        otr = dup
        otr.extend Here_::Magnetics_::FindCommand_via_Arguments  # pattern #[#sl-003]
        otr.execute
      end
    end
  end
end
