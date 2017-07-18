module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::README_File < Task_[]

      depends_on(
        :Sidesystem_Directory,
      )

      def execute

        # we don't create one for you. if there's no readme file, we stop.

        rsx = @Sidesystem_Directory

        @basename = 'README.md'

        path = ::File.join rsx.sidesystem_path, @basename

        if rsx.filesystem.exist? path
          ACHIEVED_
        else

          @_listener_.call :error, :expression do |y|
            y << "this file must exist before we can continue - #{ path }"
            y << "create that file in markdown with a first paragraph"
            y << "with two sentences and try again"
          end

          UNABLE_
        end
      end

      def resources_
        @Sidesystem_Directory  # ick/meh
      end

      # ==
      # ==
    end
  end
end
