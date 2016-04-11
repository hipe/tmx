module Skylab::MyTerm

  Terminal_Adapters_ = ::Module.new
  Terminal_Adapters_::Iterm = ::Module.new
  class Terminal_Adapters_::Iterm::Osascript_via_Path < Callback_::Actor::Monadic

    def initialize path, & oes_p

      @_oes_p = oes_p
      @_unsanitized_image_path = path
    end

    def execute

      path = @_unsanitized_image_path

      if /[\\" ]/ =~ path || path.length.zero?
        self._COVER_ME_invalid_looking_path
      else
        remove_instance_variable :@_oes_p
        @image_path = remove_instance_variable :@_unsanitized_image_path
        freeze
      end
    end

    def send_into_system_conduit_ sycond, & oes_p

      s_a = ___get_string_array

      _i, o, e, w = sycond.popen3( s_a )

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

    def express_into_under y, _
      _write_script_lines_into y
    end

    def ___get_string_array

      s_a = 'osascript', '-e'
      s_a.push ___get_script_string
      s_a
    end

    def ___get_script_string
      _write_script_lines_into ""
    end

    def _write_script_lines_into y

      _path = @image_path

      _big_s = <<-HERE.gsub %r(^[ ]{8}), EMPTY_S_
        tell application "iTerm"
          tell current session of current window
            set background image to "#{ _path }"
          end tell
        end tell
      HERE

      _s_a = _big_s.split %r((?<=\n))
      _s_a.each do |s|
        y << s
      end
      y
    end

    NEWLINE_ = "\n"
  end
end
