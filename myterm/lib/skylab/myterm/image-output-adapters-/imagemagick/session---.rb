module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class Session___

      class << self
        alias_method :begin_cold_session__, :new
        private :new
      end  # >>

      def initialize acs
        @ACS = acs
      end

      def set_background_image__ & oes_p

        osa_script = build_osa_script_( & oes_p )

        if osa_script
          ___maybe_emit_info_about_the_osa_script osa_script, & oes_p

          _sycond = @_kernel.silo( :Installation ).system_conduit

          osa_script.send_into_system_conduit_ _sycond, & oes_p
        else
          osa_script
        end
      end

      def ___maybe_emit_info_about_the_osa_script osa_script, & oes_p

        @_oes_p.call :info, :expression, :command do |y|

          y << "(attempting: #{ osa_script.thru_shellescape_ })"
        end
        NIL_
      end

      def build_osa_script_ & oes_p

        im_cmd = build_imagemagick_command_( & oes_p )
        if im_cmd
          _path = im_cmd.image_path
          Home_::Terminal_Adapters_::Iterm::Osascript_via_Path[ _path, & oes_p ]
        else
          im_cmd
        end
      end

      def build_imagemagick_command_ & oes_p

        _installation = @ACS.kernel_.silo :Installation

        o = Here_::Imagemagick_Command_via_Appearance___.new( & oes_p )
        o.appearance = @ACS
        o.image_output_path = _installation.get_volatile_image_path
        o.execute
      end
    end
  end
end
