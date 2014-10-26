module Skylab::Brazen

  module Entity

    class Event__

      class Wrappers__::File_utils_message

        Callback_::Actor.call self, :properties,
          :msg

        def execute
          @md = PATH_HACK_RX__.match @msg
          if @md
            work
          else
            UNABLE_
          end
        end

        PATH_HACK_RX__ = %r( (\A.*[^ ][ ])  ( /[^ ]+ \z ) )x

        def work
          _message_head, _path = @md.captures
          Event__.inline_with :file_utils_event,
              :path, _path,
              :message_head, _message_head,
              :ok, nil do |y, o|

            y << "#{ o.message_head }#{ pth o.path }"
          end
        end
      end
    end
  end
end
