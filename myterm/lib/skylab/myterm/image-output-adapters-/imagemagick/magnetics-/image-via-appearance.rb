module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class Magnetics_::Image_via_Appearance < Common_::Monadic

      def initialize mags, & p
        @_mags = mags ; @_oes_p = p
      end

      def execute

        ok = true
        ok &&= __resolve_IM_command
        ok && __maybe_emit_info_about_IM_command
        ok && __image_via_IM_command
      end

      def __image_via_IM_command

        _sycond = @_mags.system_conduit_

        ok = @_IM_command.send_into_system_conduit_ _sycond, & @_oes_p
        if ok
          @_IM_command.image_path
        else
          ok
        end
      end

      def __maybe_emit_info_about_IM_command

        o = @_IM_command

        @_oes_p.call :info, :expression, :command do |y|

          y << "(attempting: #{ o.thru_shellescape_ })"
        end
        NIL_
      end

      def __resolve_IM_command
        ok = @_mags.resolve_IM_command_
        ok and @_IM_command = @_mags.IM_command_
        ok
      end
    end
  end
end
# #history: broke out of session
