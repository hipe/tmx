module Skylab::MyTerm

  class Terminal_Adapters_::Iterm

    class Magnetics_::OSA_Script_via_Image < Callback_::Actor::Monadic

      # (cold.)

      def initialize mags, & oes_p

        @_oes_p = oes_p
        @_unsanitized_image_path = mags.image_
      end

      def execute
        _ok = __sanitize_image_path
        _ok && __resolve_vendor_OSA_script
      end

      def express_into_under y, _
        @_OSA_script.each_line( & y.method( :<< ) )
        y
      end

      def send_into_system_conduit_ sycond, & oes_p

        ok_x = @_OSA_script.send_into_system_conduit sycond, & oes_p
        if ok_x

          md = %r(\Ascript result: apparently set bg image to (.+)$).match ok_x
          if md && md[ 1 ] == @image_path

            ___when_apparently_succeeded( & oes_p )
          else
            self._COVER_ME_system_rejected_request
          end
        else
          ok_x
        end
      end

      def ___when_apparently_succeeded & oes_p

        path = @image_path

        oes_p.call :info, :expression, :success do |y|
          y << "apparently set iTerm background image to #{ pth path }"
        end

        ACHIEVED_
      end

      # --

      def __resolve_vendor_OSA_script

        _ = <<-HERE.gsub( %r(^[ ]{10}), EMPTY_S_ ).freeze
          tell application "iTerm2"
            tell current session of current window
              set background image to "#{ @image_path }"
            end tell
          end tell
          return "script result: apparently set bg image to #{ @image_path }"
        HERE

        @_OSA_script = Home_::Terminal_Adapter_::OSA_Script.via_one_big_string _

        remove_instance_variable :@_oes_p
        freeze
      end

      def __sanitize_image_path
        path = @_unsanitized_image_path

        if /[\\" ]/ =~ path || path.length.zero?
          self._COVER_ME_invalid_looking_path
        else
          @image_path = remove_instance_variable :@_unsanitized_image_path
          ACHIEVED_
        end
      end
    end
  end
end
