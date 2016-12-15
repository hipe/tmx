module Skylab::CodeMetrics

    class Magnetics_::Line_Count_via_Grep_Chain

      attr_writer(
        :file_array,
        :filter_array,
        :label,
        :on_event_selectively,
        :system_conduit,
        :totaller_class,
      )

      def execute

        # (we can't preserve the command as string tokens b.c pipes)

        a = @filter_array.dup
        a.push 'wc -l'
        cmd_tail_s = a.join ' | '

        totes = @totaller_class.new
        totes.slug = @label
        @_totes = totes

        lib = Home_.lib_

        ok = ACHIEVED_

        @file_array.each do | file |

          cmd_s = "cat #{ lib.shellescape_path file } | #{ cmd_tail_s }"

          @on_event_selectively.call :info, :data, :wc_pipey_command_string do
            cmd_s
          end

          _, o, e, w = @system_conduit.popen3 cmd_s

          y = Home_::ThroughputAdapters_::SynchronousRead.call(
            [], nil, o, e, w, & @on_event_selectively )

          if y
            ok = __process_lines y, file
          else
            ok = UNABLE_
            break
          end
        end

        if ok

          totes = @_totes
          _d = totes.to_child_stream.to_enum.reduce 0 do | m, cx |
            m + cx.count
          end
          totes.count = _d
          totes
        end
      end

      def __process_lines y, file
        case 1 <=> y.length
        when 0
          __process_one_line y.fetch( 0 ), file
        when -1
          raise ::SystemError, __say_extra( y )
        when 1
          raise ::SystemError, __say_none
        end
      end

      def __say_extra y
        "unexpected line: #{ y[ 1 ].inspect }"
      end

      def __say_none
        "expecting some output lines. had none"
      end

      def __process_one_line line, file

        md = RX___.match line
        if md

          totes = @totaller_class.new
          totes.slug = file
          totes.count = md[ :num ].to_i

          @_totes.append_child_ totes

          ACHIEVED_
        else
          raise ::SystemError, __say_md( line )
        end
      end

      RX___ = /\A [[:space:]]* (?<num> \d+ ) [[:space:]]* \z/x

      def __say_md line
        "expected numeric line: #{ line.inspect }"
      end
    end
  # -
end
