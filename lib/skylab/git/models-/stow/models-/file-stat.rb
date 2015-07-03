module Skylab::Git

  class Models_::Stow

    class Models_::File_Stat

      # a file "stat" in this context summarizes the diff that expresses
      # this file (see sibling). the subject simply encapsulates the number
      # of lines that this diff adds (i.e the number of lines in the file)
      # and the stow-local filename.

      attr_reader(
        :combined,
        :deletions,
        :insertions,
      )

      def name
        @name
      end

      def initialize patch_item_stream, rsc, & oes_p

        @deletions = 0
        @insertions = 0

        begin
          item = patch_item_stream.gets
          item or break

          case item.category_symbol

          when :file_info
            __tick_file_info item

          when :chunk_header
            __tick_chunk_header item

          when :add, :context, :remove
            # nothing.
            #
          else
            self._CASE
          end

          redo
        end while nil

        @combined = @deletions + @insertions

        freeze
      end

      def __tick_file_info item

        if item.is_before
          if DEV_NULL___ != item.path
            self._COVER_ME
          end
        else
          @name = item.path
        end
        NIL_
      end

      DEV_NULL___ = '/dev/null'

      def __tick_chunk_header item

        @deletions += item.deletions_count
        @insertions += item.insertions_count
        NIL_
      end
    end
  end
end
