module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Gem_File_Builds < Task_[]

      depends_on :Gemspec_File

      def execute

        name = @name

        @on_event_selectively.call :info, :expression do | y |
          y << "(\"#{ name.as_const }\" not yet implemented as task..)"
        end

        ACHIEVED_
      end
    end
  end
end
