module Skylab::Git

  class Models_::Stow

    class Models_::Item

      # a stow "item" is typically (alwyas?) a text file. subject is a
      # higher level accesspoint for the different ways such files are
      # expressed when part of a stow.

      class << self

        def curry s, rsc, & x_p
          o = new
          o.__curry s, rsc, & x_p
        end

        private :new
      end  # >>

      attr_reader(
        :file_relpath,
      )

      def __curry s, o, & p

        @listener = p
        @resources = o
        @stow_path = s
        freeze
      end

      def [] path
        dup.__init path
      end

      protected def __init path

        @file_relpath = path
        self
      end

      def to_any_styled_patch_line_stream

        st = _to_any_patch_item_stream
        if st
          st.map_by do | item |
            item.to_styled_line
          end
        end
      end

      def to_any_non_styled_patch_line_stream

        st = _to_any_patch_item_stream
        if st
          st.map_by do | item |
            item.to_non_styled_line
          end
        end
      end

      def to_any_file_stat

        st = _to_any_patch_item_stream
        if st
          Models_::File_Stat.new(
            st,
            @resources,
            & @listener )
        end
      end

      def _to_any_patch_item_stream

        fp = Models_::File_Patch.any(
          @file_relpath,
          @stow_path,
          @resources,
          & @listener )

        if fp
          fp.to_patch_item_stream
        end
      end
    end
  end
end
