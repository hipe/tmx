module Skylab::GitViz

  module Test_Lib_

    module Mock_Sys

      class Recording_Session__

        def initialize byte_downstream, & edit_p
          @bd = byte_downstream
          @edit_p = edit_p
          @is_first = true
        end

        def execute
          @edit_p[ self ]
          ACHIEVED_
        end

        def popen3 * argv

          block_given? and raise ::ArgumentError

          _i, o, e, t = GitViz_.lib_.open3.popen3( * argv )

          co = Mock_Sys_::Models_::Command.new

          co.argv = argv

          co.stdout_string = o.read  # etc
          co.stderr_string = e.read  # etc

          co.exitstatus = t.value.exitstatus

          if @is_first
            @is_first = false
          else
            @bd.write NEWLINE_
          end

          co.write_to @bd

          co.to_four
        end
      end
    end
  end
end
