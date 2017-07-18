module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::For_TMX_Map_File < Task_[]

      depends_on(
        :Sidesystem_Directory,
      )

      def execute  # shmeless copy-paste-modify of README task

        _TMX = Common_::Autoloader.require_sidesystem :TMX
        _file = _TMX::METADATA_FILENAME

        rsx = @Sidesystem_Directory

        path = ::File.join rsx.sidesystem_path, _file
        @path = path

        if rsx.filesystem.exist? path
          ACHIEVED_
        else

          @_listener_.call :error, :expression do |y|
            y << "this file must exist before we can continue - #{ path }"
            y << "for now, it is suggested that you simply copy one such file"
            y << "from a semantically similar sidesystem and modify it"
            y << "as appropriate. (these files are short and simple)."
            y << nil
            y << "if desired, use the"
            y << "    #{ THIS_ONE_SCRIPT_ } script"
            y << "to re-allocate sigils to determine one for this new sidesystem."
          end

          UNABLE_
        end
      end

      def resources_
        @Sidesystem_Directory
      end

      attr_reader(
        :path,
      )

      # ==
      # ==
    end
  end
end
