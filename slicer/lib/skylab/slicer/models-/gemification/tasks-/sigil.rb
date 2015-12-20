module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Sigil < Task_[]

      depends_on :Sidesystem_Directory

      def execute

        @basename = ::File.basename @Sidesystem_Directory.path
        stem = @basename

        _st = Home_.lib_.TMX.build_sigilized_sidesystem_stream_plus stem

        _sigilization = _st.flush_until_detect do | s10n |
          stem == s10n.stem
        end

        @sigil = _sigilization.sigil
        ACHIEVED_
      end

      attr_reader(
        :basename,
        :Sidesystem_Directory,
        :sigil,
      )
    end
  end
end
