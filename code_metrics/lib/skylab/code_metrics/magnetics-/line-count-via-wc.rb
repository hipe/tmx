module Skylab::CodeMetrics

    class Magnetics_::Line_Count_via_WC  # read [#001]

      attr_writer(

        :file_array,
        :label,
        :on_event_selectively,
        :system_conduit,
        :totaller_class,
      )

      def execute

        totes = @totaller_class.new
        totes.slug = @label
        @_totes = totes

        ok = if @file_array.length.zero?

          self._MAYBE_ZERO_IT_OUT
        else
          __when_nonzero_file_array
        end
        if ok
          tot = @_totes
          tot.count or self._SANITY
          tot
        else
          ok
        end
      end

      def __when_nonzero_file_array  # [#001] is highly recommended reading

        ok = __resolve_command_string
        ok &&= __via_command_string_resolve_output_lines
        ok && __via_output_lines_resolve_accretion
      end

      def __resolve_command_string

        # (we would build this as a tokenized array but for the pipe: [#011])

        cmd = [ 'wc', '-l' ]

        sw = Home_.lib_.shellwords

        @file_array.each do | s |
          s or self._SANITY
          cmd.push sw.shellescape s
        end

        cmd.push '|', 'sort', '--general-numeric-sort'

        cmd_s = cmd * SPACE_  # BE CAREFUL

        @on_event_selectively.call :info, :data, :wc_command do
          WC_Command___.new cmd_s
        end

        @_command_string = cmd_s
        ACHIEVED_
      end

      WC_Command___ = ::Struct.new :to_string

      def __via_command_string_resolve_output_lines

        _, o, e, w = @system_conduit.popen3 @_command_string  # (was [#004])

        y = Home_::ThroughputAdapters_::SynchronousRead.call(
          [], nil, o, e, w, & @on_event_selectively )

        if y
          @_output_lines = y
          ACHIEVED_
        else
          y
        end
      end

      def __via_output_lines_resolve_accretion

        @_output_lines.length.zero? and self._NEVER

        case 1 <=> @file_array.length
        when -1
          __when_many
        when 0
          __when_one
        else
          self._NEVER
        end
      end

      def __when_one

        _ok = _accrue_counts_from_range_of_output_lines 0
        _ok && ___finish_one
      end

      def ___finish_one

        # ridiculous gotcha -  when you have only one we don't have the
        # finaly summary line from `wc` to do the math for us! eek

        @_totes.count = @_totes.at_position( 0 ).count
        ACHIEVED_
      end

      def __when_many

        _ok = _accrue_counts_from_range_of_output_lines( -2 )
        _ok && __finish_many
      end

      def __finish_many

        line = @_output_lines.fetch( -1 )

        md = WC_TOTAL_LINE_RX___.match line

        if md
          @_totes.count = md[ 1 ].to_i
          ACHIEVED_
        else
          raise ::SystemError, __say_totes( line )
        end
      end

      WC_TOTAL_LINE_RX___ = /\A *(\d+) total\z/

      def __say_totes line
        "expecting total line - #{ line }"
      end

      def _accrue_counts_from_range_of_output_lines end_

        line_a = @_output_lines

        stopper = if 0 > end_
          line_a.length + end_
        else
          end_
        end

        d = -1
        rx = /\A *(?<num>\d+) (?<label>.+)\z/

        while d < stopper
          d += 1
          line = line_a.fetch d
          md = rx.match line  # :[#002]
          if md
            totes = @totaller_class.new
            totes.slug = md[ :label ]
            totes.count = md[ :num ].to_i
            @_totes.append_child_ totes
          else
            raise ::SystemError, __say( line )
          end
        end

        ACHIEVED_
      end

      def __say line
        "expecting integer token - #{ line }"
      end
    end
  # -
end
