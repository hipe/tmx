module Skylab::System
  # -
    class Services___::Find

      Expression_Adapters::Event = Common_::Event.prototype_with(
         :find_command_args,
         :find_command_args, nil,
         :ok, nil,
      ) do | y, o |

        sw = Home_.lib_.shellwords

        _ = o.find_command_args.map do | s |
          sw.shellescape s
        end.join SPACE_

        y << "generated `find` command: \"#{ _ }\""
      end

      class Expression_Adapters::Event

        class << self

          # egads - expr.ada needs the one, event needs the other

          def [] cmd
            super cmd.args
          end
        end  # >>
      end
    end
  # -
end
