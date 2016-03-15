module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::README_File < Task_[]

      depends_on :Sidesystem_Directory

      def execute

        # we don't create one for you. if there's no readme file, we stop.

        dir = @Sidesystem_Directory

        @basename = 'README.md'

        path = ::File.join dir.path, @basename

        if dir.filesystem.exist? path
          ACHIEVED_
        else

          @_oes_p_.call :error, :expression do | y |
            y << "this file must exist before we can continue - #{ path }"
            y << "create that file in markdown with a first paragraph"
            y << "with two sentences and try again"
          end

          UNABLE_
        end
      end

      attr_reader :basename
    end
  end
end
