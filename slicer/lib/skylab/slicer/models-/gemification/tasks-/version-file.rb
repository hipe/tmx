module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::VERSION_File < Task_[]

      depends_on(
        :Sidesystem_Directory,
      )

      def execute

        sd = @Sidesystem_Directory

        @basename = 'VERSION'

        path = ::File.join sd.sidesystem_path, @basename

        if sd.filesystem.exist? path
          @version_string = ::File.read( path ).chomp!.freeze
          ACHIEVED_
        else
          @version_string = "0.0.0".freeze
          ::File.write path, @version_string
          ACHIEVED_
        end
      end

      attr_reader(
        :version_string,
      )

      # ==
      # ==
    end
  end
end
# #tombstone-A: (can be temporary) more complicated file write
