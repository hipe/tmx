module Skylab::MyTerm

  class Terminal_Adapters_::Iterm

    class Magnetics_::Set_Background_Image_via_Image < Common_::Actor::Monadic

      # depends_on :OSA_Script, :Compatible_Version_of_Iterm (would be)

      def initialize o, & p
        @_mags = o ; @_oes_p = p
      end

      def execute
        ok = true
        ok &&= __resolve_OSA_script
        ok &&= @_mags.check_version_of_iterm_
        ok && __via_OSA_script_set_BGI
      end

      def __via_OSA_script_set_BGI

        _sycon = @_mags.system_conduit_
        @_OSA_script.send_into_system_conduit_ _sycon, & @_oes_p
      end

      def __resolve_OSA_script

        ok = @_mags.resolve_OSA_script_
        ok and @_OSA_script = @_mags.OSA_script_
        ok
      end
    end
  end
end
