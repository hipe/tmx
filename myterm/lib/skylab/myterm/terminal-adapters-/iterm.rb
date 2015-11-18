module Skylab::MyTerm

  Terminal_Adapters_ = ::Module.new

  class Terminal_Adapters_::Iterm

    def initialize ke
      @_kernel = ke
    end

    def set_background_image_to path, & x_p

      if /[\\" ]/ =~ path || path.length.zero?
        self._COVER_ME_invalid_looking_path
      else
        ___set_background_image_to_valid_looking_path path, & x_p
      end
    end

    def ___set_background_image_to_valid_looking_path path, & oes_p_NOT_USED_YET

      _script = <<-HERE
        tell application "iTerm"
          tell current session of current window
            set background image to "#{ path }"
          end tell
        end tell
      HERE

      _i, o, e, w = ___system_conduit.popen3 'osascript', '-e', _script

      s = e.gets
      if s
        self._COVER_ME_did_not_succeed
      else

        s = o.gets
        s and self._COVER_ME_unexpected_stdout_output_easy_enough

        if w.value.exitstatus.zero?
          ACHIEVED_
        else
          self._COVER_ME_unexpected_result_value
        end
      end
    end

    def ___system_conduit
      @_kernel.silo( :Installation ).system_conduit
    end
  end
end
