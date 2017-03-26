module Skylab::Common

  module Magnetics_

    MessageProc_via_MapReducer_and_MessageProc = -> map_reduce_p, old_message_proc do

          -> y, o do

            line_index = -1

            y_ = ::Enumerator::Yielder.new do |s|
              line_index += 1
              s_ = instance_exec s, line_index, & map_reduce_p
              if s_
                y << s_
              end
            end

            instance_exec y_, o, & old_message_proc
            NIL_
          end

    end

    # ==
    # ==
  end
end
