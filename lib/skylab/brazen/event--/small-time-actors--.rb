module Skylab::Brazen

  module Entity

    class Event__

      module Small_Time_Actors__

        Produce_new_message_proc_from_map_reducer_and_old_message_proc =

            -> map_reduce_p, old_message_proc do

          -> y, o do

            y_ = ::Enumerator::Yielder.new do |s|
              s_ = instance_exec s, & map_reduce_p
              if s_
                y << s_
              end
            end

            instance_exec y_, o, & old_message_proc
            nil
          end
        end
      end
    end
  end
end
