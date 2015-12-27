module Skylab::Snag

  class Models_::To_Do

    Sessions_ = ::Module.new

    class Sessions_::Collection

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      attr_writer :filename_pattern_s_a, :path_s_a, :pattern_s_a,

        :system_conduit

      def to_stream

        cmd = build_system_command
        cmd and begin

          @command = cmd

          p = @on_event_selectively

          st = Actors_::Matching_line_stream_via_find_command[
            cmd, @system_conduit, & p ]

          st and begin

            Actors_::To_do_stream_via_matching_line_stream[
              st, @pattern_s_a, & p ]
          end
        end
      end

      attr_reader :command

      def build_system_command

        otr = dup
        otr.extend To_Do_::Actors_::Build_the_find_command  # pattern #[#sl-003]
        otr.execute
      end
    end
  end
end
