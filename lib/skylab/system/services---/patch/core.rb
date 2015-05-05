module Skylab::Headless

  module System__

    class Services__::Patch

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

      def new patch_content_x
        Patch_::Models__::ContentPatch.new patch_content_x
      end

      def call * x_a, & p
        Curry__.call_via_iambic x_a, & p
      end

      class Curry__

        Callback_::Actor.methodic self

        def initialize & edit_p
          @on_event_selectively = nil
          @dry = nil
          @patch_method = nil
          @target_method = nil
          instance_exec( & edit_p )
        end

      private

        def accept_selective_listener_proc p
          @on_event_selectively = p
          nil
        end

        def is_dry_run=
          @dry = iambic_property
          KEEP_PARSING_
        end

        def on_event_selectively=
          @on_event_selectively = iambic_property
          KEEP_PARSING_
        end

        def patch_file=
          x = iambic_property
          if x
            @patch_method = :via_patch_file
            @patch_file = x
          elsif :via_patch_file == @patch_method
            @file = x
          end
          KEEP_PARSING_
        end

        def patch_string=
          x = iambic_property
          if x
            @patch_method = :via_patch_string
            @patch_string = x
          elsif :via_patch_string == @patch_method
            @patch_string = x
          end
          KEEP_PARSING_
        end

        def target_directory=
          x = iambic_property
          if x
            @target_method = :against_directory
            @target_directory = x
          elsif :against_directory == @target_method
            @target_directory = x
          end
          KEEP_PARSING_
        end

        def target_file=
          x = iambic_property
          if x
            @target_method = :against_file
            @target_file = x
          elsif :against_file == @target_method
            @target_file = x
          end
          KEEP_PARSING_
        end

      public

        def execute
          if @target_method
            wait_process
          else
            freeze
          end
        end

      private

        def wait_process

          i, o, e, w = Headless_::Library_::Open3.popen3 build_command_string

          if :via_patch_string == @patch_method
            i.write @patch_string
            i.close
          end

          x = e.read
          if x.length.nonzero?
            serr_line = x
          end

          s = o.gets
          while s
            if @on_event_selectively
              @on_event_selectively.call :info, :process_line do
                Process_Line_[ s ].to_event
              end
            end
            s = o.gets
          end

          status = w.value

          if status.exitstatus.zero?
            serr_line and self._DO_ME
            ACHIEVED_
          elsif @on_event_selectively
            @on_event_selectively.call :error, :nonzero_exitstatus do
              build_nonzero_event status, serr_line
            end
          else
            raise ::SystemCallError, ( serr_line || "patch failed" )
          end
        end

        def build_nonzero_event status, serr_line

          Callback_::Event.inline_not_OK_with :nonzero_exitstatus,
              :exitstatus, status.exitstatus,
              :first_error_line, serr_line do | y, o_ |

            y << "#{ o_.first_error_line || 'nonzero exitstatus' } #{
              }(exitstatus: #{ o_.exitstatus })"
          end
        end

        def build_command_string

          cmd = [ 'patch' ]

          if :against_directory == @target_method
            cmd.push "--directory=#{ esc @target_directory }"
            cmd.push '-p1'
          end

          if @dry
            cmd.push '--dry-run'
          end

          if :via_patch_file == @patch_method
            cmd.push "--input=#{ esc @patch_file }"
          end

          if :against_file == @target_method
            cmd.push esc @target_file
          end


          cmd * SPACE_
        end

        def esc s
          Headless_::Library_::Shellwords.shellescape s
        end

        Process_Line_ = Callback_::Event.message_class_factory.new :ok, nil do | line |
          line
        end
      end

      Patch_ = self
    end
  end
end
