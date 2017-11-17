module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Vendor_Match_Stream_via_Files_Slice_Stream

      attr_writer(
        :files_slice_stream,
        :system_conduit,
        :pattern_strings,
      )

      def initialize( & p )
        @_on_event_selectively = p
      end

      def execute

        ok = __normalize_unsanitized_pattern_strings
        ok && __init_command_prototype
        ok && __flush_self_to_stream
      end

      def __flush_self_to_stream

        command_prototype = remove_instance_variable :@_command_prototype

        system = remove_instance_variable :@system_conduit

        st = remove_instance_variable :@files_slice_stream

        active_wait = nil
        upstream_reference = -> do
          active_wait
        end

        p = nil
        lower_mode = -> do

          chunk = st.gets
          if chunk  # asssume nonzero length
            cmd = command_prototype.dup
            cmd.concat chunk

            _i, o, e, active_wait = system.popen3( * cmd )

            p = -> do
              s = o.gets
              if s
                s.chomp!
                path, lineno_string, line_content = s.split COLON_, 3

                if INTEGER_RX___ =~ lineno_string
                  Vendor_Match___[ lineno_string.to_i, path, line_content ]
                else
                  self._COVER_ME  # e.g strange pathnames
                end
              else
                s = e.gets
                if s
                  s.chomp!
                  self._COVER_ME
                end
                p = lower_mode
                p[]
              end
            end
            p[]
          end
        end

        p = lower_mode

        Common_::Stream.by upstream_reference do
          p[]
        end
      end

      INTEGER_RX___ = /\A\d+\z/
      Vendor_Match___ = ::Struct.new :lineno, :path, :line_content

      # -- command-building

      def __init_command_prototype

        cmd = COMMON_BEGINNING___.dup

        _inner = @_normal_pattern_strings.map do | s |
          s  # (hi.)
        end.join '|'

        _outer = "\\b(#{ _inner })\\b"

        cmd.push REGEXP_SWITCH___, _outer

        @_command_prototype = cmd.freeze

        NIL_
      end

      COMMON_BEGINNING___ = [
        'grep',
        '--extended-regexp',
        '-H',  # always pring the filename headers with output lines
        '--line-number',
      ]

      REGEXP_SWITCH___ = '--regexp'

      # -- normalization

      def __normalize_unsanitized_pattern_strings

        if @pattern_strings.length.zero?
          self._COVER_ME
        else
          ___normalize_nonzero_unsanitized_pattern_strings
        end
      end

      def ___normalize_nonzero_unsanitized_pattern_strings

        bad = nil
        @pattern_strings.each do | s |
          if RX___ !~ s
            ( bad ||= [] ).push s
          end
        end

        if bad
          ___when_bad bad
        else
          _a = remove_instance_variable :@pattern_strings
          _a.freeze
          @_normal_pattern_strings = _a
          ACHIEVED_
        end
      end

      RX___ = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/

      def ___when_bad a

        @_on_event_selectively.call :error, :expression, :bad_patterns do | y |

          _ = if 1 == a.length
            ick a.first
          else
            "(#{ a.map( & method( :ick ) ).join ', ' })"
          end

          y << "invalid pattern#{ s a }, must look like a common method: #{ _ }"
        end

        UNABLE_
      end

      COLON_ = ':'
    end
  end
end
