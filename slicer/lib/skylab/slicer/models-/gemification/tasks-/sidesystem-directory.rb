module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Sidesystem_Directory < Task_[]

      depends_on_parameters :sidesystem_path, :filesystem

      def execute

        # (use [sy] if the below gives you any annoyance)

        begin
          stat = @filesystem.stat @sidesystem_path
        rescue ::Errno::ENOENT => e
        end

        if e
          @on_event_selectively.call :error, :expression do | y |
            s = e.message
            md = /\A(.+) @ [^-]+ - (.+)\z/.match s
            if md
              s = "#{ md[ 1 ] } - #{ md[ 2 ] }"
            end
            y << s
          end
          UNABLE_

        elsif 'directory' == stat.ftype

          @path = remove_instance_variable :@sidesystem_path
          ACHIEVED_
        else
          @on_event_selectively.call :error, :expression do | y |
            y << "needed directory had #{ stat.ftype } - #{ path }"
          end
          UNABLE_
        end
      end

      # ~ for dependers:

      attr_reader(
        :filesystem,
        :path,
      )
    end
  end
end
