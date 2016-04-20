module Skylab::System

  module Doubles::Stubbed_System
    # -
      class Recording_Session__

        def initialize byte_downstream, & edit_p
          @bd = byte_downstream
          @edit_p = edit_p
          @is_first = true
        end

        def execute
          if @edit_p
            @edit_p[ self ]
            ACHIEVED_
          else
            self
          end
        end

        def popen3 * args

          block_given? and raise ::ArgumentError

          _i, o, e, t = Home_.lib_.open3.popen3( * args )

          co = Here_::Readable_Writable_Based_::Popen3_Result.new

          co.receive_args args

          co.stdout_string = o.read  # etc
          co.stderr_string = e.read  # etc

          co.exitstatus = t.value.exitstatus

          if @is_first
            @is_first = false
          else
            @bd.write NEWLINE_
          end

          receive_command co

          co.to_four
        end

        def receive_command co
          co.write_to @bd
          NIL_
        end
      end
    # -
  end
end
