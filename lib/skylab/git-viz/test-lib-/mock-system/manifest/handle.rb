module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest

      class Handle < Manifest_IO___

        def initialize pn
          super
        end

        def get_command_scanner_scanner
          a = @cmd_as_non_unique_key_s_a ; d = -1 ; last = a.length - 1
          Scn__.new do
            if d < last
              cmd_s = a.fetch d += 1
              bld_cmd_scanner @h.fetch cmd_s
            end
          end
        end
      private
        def bld_cmd_scanner a
          d = -1 ; last = a.length - 1
          Scn__.new do
            d < last and a.fetch d += 1
          end
        end

        Scn__ = FUN_::Scn[]
      end
    end
  end
end
