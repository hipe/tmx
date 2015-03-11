module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Manifest_ < Manifest_

        attr_reader :manifest_pathname  # only used by server plugins omz
        def manifest_summary
          "#{ @entry_count } entries (#{ unique_commands_count }#{
            } unique commands)"
        end
        attr_reader :entry_count
        def unique_commands_count
          @cmd_as_non_unique_key_s_a.length
        end

        def get_command_stream_stream
          a = @cmd_as_non_unique_key_s_a ; d = -1 ; last = a.length - 1
          Callback_::Scn.new do
            if d < last
              cmd_s = a.fetch d += 1
              bld_cmd_stream @cmd_a_h.fetch cmd_s
            end
          end
        end
      private
        def bld_cmd_stream a
          d = -1 ; last = a.length - 1
          Callback_::Scn.new do
            d < last and a.fetch d += 1
          end
        end
      end
    end
  end
end
