module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::VERSION_File < Task_[]

      depends_on :Sidesystem_Directory, :Sigil

      def execute

        sd = @Sidesystem_Directory

        @basename = 'VERSION'

        path = ::File.join sd.path, @basename

        if sd.filesystem.exist? path
          ACHIEVED_
        else

          _content = "0.0.0.#{ @Sigil.sigil }.pre.bleeding"
          io = sd.filesystem.open path, ::File::WRONLY | ::File::CREAT
          io.puts _content
          io.close
          ACHIEVED_
        end
      end

      attr_reader :basename
    end
  end
end
