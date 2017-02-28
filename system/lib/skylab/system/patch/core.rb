module Skylab::System

  module Patch

    class Service

      # using the host system's `patch` utility (whatever it is (if any)),
      # apply a patch specified in a string or via a path to the specified
      # file or directory. the previous sentence introduced two categories
      # with two of their own categories of value respectively: a category
      # "patch" is expressed either by a "string" or a "path" value, and a
      # category "target" is expressed by a directory or file value. these
      # value categories are mutually exclusive with respect to each other
      # in their category: the last true-ish value provided determines the
      # value category for that category; e.g if you provide both a string
      # and a path for patch input the string will be ignored and the path
      # will be employed, because it was passed last.
      #
      # when false-ish values are passed, behavior is officially undefined
      # but will perhaps be handled in a way that makes secret sense.
      #
      # if no target (that is, neither directory nor file) is mentioned in
      # the input iambic, this is assume to be a request to make a curried
      # object; which is behavior perhaps not yet fully implemented.
      #

      def initialize _svx
      end

      def new_via_file_content_before file_content_x

        Patch_::Models__::Mutable_Progressive.via_file_content_before_ file_content_x
      end

      def call_via_arglist x_a, & p
        if x_a.length.nonzero? || p
          Curry___.call_via_iambic x_a, & p
        else
          self
        end
      end

      class Curry___

        Attributes_actor_.call( self,
          system_conduit: nil,
        )

        def initialize & oes_p

          if oes_p
            -1 == oes_p.arity or self._MODERNIZE_ME
            @on_event_selectively = oes_p
          end

          @dry = nil
          @patch_method = nil
          @system_conduit = nil
          @target_method = nil
        end

      private

        def is_dry_run=
          @dry = gets_one
          KEEP_PARSING_
        end

        def patch_file=
          x = gets_one
          if x
            @patch_method = :via_patch_file
            @patch_file = x
          elsif :via_patch_file == @patch_method
            @file = x
          end
          KEEP_PARSING_
        end

        def patch_lines=
          x = gets_one
          if x
            @patch_method = :via_lines
            @patch_lines = x
          elsif :via_lines == @patch_method
            @patch_lines = x
          end
          KEEP_PARSING_
        end

        def patch_string=
          x = gets_one
          if x
            @patch_method = :via_patch_string
            @patch_string = x
          elsif :via_patch_string == @patch_method
            @patch_string = x
          end
          KEEP_PARSING_
        end

        def target_directory=
          x = gets_one
          if x
            @target_method = :against_directory
            @target_directory = x
          elsif :against_directory == @target_method
            @target_directory = x
          end
          KEEP_PARSING_
        end

        def target_file=
          x = gets_one
          if x
            @target_method = :against_file
            @target_file = x
          elsif :against_file == @target_method
            @target_file = x
          end
          KEEP_PARSING_
        end

        def execute

          if @target_method
            wait_process
          else
            freeze
          end
        end
        public :execute

        def wait_process

          _cond = @system_conduit || Home_.lib_.open3

          i, o, e, w = _cond.popen3( * build_command_string_array )

          send :"__#{ @patch_method }__write_into_stdin", i  # closes stdin

          s = e.gets
          if s
            __when_error_line s, e, w
          else
            __when_probably_succeeded o, w
          end
        end

        def __when_probably_succeeded o, w

          if @on_event_selectively

            begin
              s = o.gets
              s or break
              -> s_ do
                @on_event_selectively.call :info, :process_line do
                  Process_Line_[ s_ ].to_event
                end
              end.call s
              redo
            end while nil
          end

          d = w.value.exitstatus
          if d.zero?
            ACHIEVED_
          else
            _maybe_emit_failure_event w
          end
        end

        def __when_error_line first_s, e, w

          # we run the error stream down to the end and ignore the out
          # stream. we "wait the thread" below, not wanting the event
          # handler to be the one that decides when to finish the process.

          s_a = []

          if first_s
            s_a.push first_s
          end

          begin
            s = e.gets
            s or break
            s_a.push s
          end while nil

          _maybe_emit_failure_event s_a, w
        end

        def _maybe_emit_failure_event s_a=nil, w

          d = w.value.exitstatus

          if @on_event_selectively

            @on_event_selectively.call :error, :nonzero_exitstatus do

              __build_nonzero_event d, s_a
            end
          else
            _s = if s_a
              s_a.first
            end
            raise ::SystemCallError, ( _s || "patch failed" )
          end
        end

        def __build_nonzero_event d, s_a

          Common_::Event.inline_not_OK_with(

            :nonzero_exitstatus,
            :exitstatus, d,
            :error_lines, s_a

          ) do | y, o |

            if o.error_lines
              _s = o.error_lines.first
            end

            y << "#{ _s || 'nonzero exitstatus' } #{
              }(exitstatus: #{ o.exitstatus })"
          end
        end

        def __via_patch_file__write_into_stdin i

          # the file argument was passes as an argument (option)
          i.close
          NIL_
        end

        def __via_lines__write_into_stdin i

          st = @patch_lines
          begin
            line = st.gets
            line or break
            i.puts line  # or `write` if you're feeling lucky
            redo
          end while nil
          i.close  # nil
          NIL_
        end

        def __via_patch_string__write_into_stdin i

          i.write @patch_string
          i.close
          NIL_
        end
        def build_command_string_array

          cmd = [ 'patch' ]

          if :against_directory == @target_method
            cmd.push "--directory=#{ _esc @target_directory }"
            cmd.push '-p1'
          end

          if @dry
            cmd.push '--dry-run'
          end

          if :via_patch_file == @patch_method
            cmd.push "--input=#{ _esc @patch_file }"
          end

          if :against_file == @target_method
            cmd.push _esc @target_file
          end

          cmd
        end

        def _esc s
          Home_.lib_.shellwords.shellescape s
        end

        Process_Line_ = Common_::Event.message_class_maker.new :ok, nil do | line |
          line
        end
      end
    end
    Patch_ = self
  end
end
