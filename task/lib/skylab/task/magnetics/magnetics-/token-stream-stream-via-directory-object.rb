self._NOT_yet_refactored

class Skylab::Task

  module Magnetics

    class Magnetics_::MeansStream_via_Path

      def initialize path, fs, & oes_p
        @FS = fs
        @path = path
        @_oes_p = oes_p
      end

      def execute
        ok = __resolve_entries_array
        ok && __init_prepared_entry_stream
        ok && __finish
      end

      def __finish

        @_prepared_entry_stream.map_by do |entry|

          stem = entry[ 0 ... - ::File.extname( entry ).length ]

          md = VIA_RX___.match stem

          if md
            slug_A = md[ :first ]
            slug_Bs = md[ :second ].split AND___
          else
            slug_A = stem
          end

          Models_::Means.new slug_Bs, slug_A
        end
      end

      AND___ = '-and-'
      _ = '(?:(?!-via-).)+'
      VIA_RX___ = /\A(?<first>#{_})-via-(?<second>#{_})\z/

      def __init_prepared_entry_stream

        _ = remove_instance_variable :@_entries_array
        st = Common_::Polymorphic_Stream.via_array _
        rx = /\A\.+\z/
        while rx =~ st.current_token
          st.advance_one
        end
        @_prepared_entry_stream = st.flush_to_stream
        NIL_
      end

      def __resolve_entries_array

        begin
          @_entries_array = @FS.entries @path
          ACHIEVED_
        rescue ::SystemCallError => e
          @_oes_p.call :error, :expression do |y|
            y << e.message  # etc
          end
          UNABLE_
        end
      end
    end
  end
end
