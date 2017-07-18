module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Sidesystem_Directory < Task_[]

      depends_on_parameters(
        :sidesystem_path,
        :script_invocation,
      )

      def execute

        # (use [sy] if the below gives you any annoyance)

        begin
          stat = filesystem.stat @sidesystem_path
        rescue ::Errno::ENOENT => e
        end

        if e
          @_listener_.call :error, :expression do |y|
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
          @_listener_.call :error, :expression do |y|
            y << "needed directory had #{ stat.ftype } - #{ path }"
          end
          UNABLE_
        end
      end

      # -- as "resources"

      def this_one_script
        _script_path :_reallocate_sigils_
      end

      def this_other_script
        _script_path :_essentials_script_
      end

      def _script_path k
        @script_invocation.script_path_ k
      end

      def sidesystem_path
        @path
      end

      def batch_cache
        @script_invocation.batch_cache
      end

      def stderr
        @script_invocation.stderr
      end

      def filesystem
        @script_invocation.filesystem
      end

      # ==
      # ==
    end
  end
end
