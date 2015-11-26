module Skylab::MyTerm

  class Image_Output_Adapters_::Imagemagick

    class Build_and_send_image_ < Callback_::Actor::Dyadic

      def initialize snapshot, kernel, & oes_p
        @_kernel = kernel
        @_oes_p = oes_p
        @_snapshot = snapshot
      end

      def execute

        ok = ___resolve_command
        ok && __emit_info
        ok &&= __build_image
        ok && __send_image
      end

      def ___resolve_command

        _installation = @_kernel.silo :Installation

        o = Here_::Build_command_.new( & @_oes_p )

        o.image_output_path = _installation.get_volatile_image_path
        o.snapshot = @_snapshot

        command = o.execute

        if command
          @_command = command
          ACHIEVED_
        else
          cmd_s_a
        end
      end

      def __emit_info

        cmd_s_a = @_command.string_array

        @_oes_p.call :info, :expression, :command do | y |

          _p = Home_.lib_.shellwords.method :shellescape

          y << "(attempting: #{ cmd_s_a.map( & _p ) * ' ' })"  # SPACE_
        end

        NIL_
      end

      def __build_image

        _system_conduit = @_kernel.silo( :Installation ).system_conduit

        _, o, @_e, @_w = _system_conduit.popen3( * @_command.string_array )

        s = @_e.gets
        if s
          ___when_one_error_line s

        else

          x = o.gets
          x and self._COVER_ME  # utility is quiet

          @_d = @_w.value.exitstatus
          if @_d.zero?
            ACHIEVED_
          else
            self._COVER_ME
          end
        end
      end

      def ___when_one_error_line s

        # (might block if you try to read more now)

        @_oes_p.call :error, :expression, :system_call_failed do | y |
          y << s
        end

        if @_w.alive?
          @_w.exit
        end

        UNABLE_
      end

      def __send_image

        _iterm = Home_::Terminal_Adapters_::Iterm.new @_kernel

        _iterm.set_background_image_to @_command.image_path, & @_oes_p
      end
    end
  end
end
