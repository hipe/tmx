module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Gem_File_Builds < Task_[]

      depends_on :Gemspec_File

      def execute

        name = @Gemspec_File.name

        @_oes_p_.call :info, :expression do | y |
          y << "(\"#{ name.as_const }\" not yet implemented as task..)"
          y << "(also, make sure you are running this from right inside the sidesystem)"
        end

        ACHIEVED_
      end
    end
  end
end
