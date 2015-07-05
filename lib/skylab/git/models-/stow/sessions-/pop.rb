module Skylab::Git

  class Models_::Stow

    class Sessions_::Pop

      attr_accessor(
        :expressive_stow,
        :filesystem,
        :project_path,
      )

      def initialize & x_p
        @on_event_selectively = x_p
      end

      def execute

        uow = Stow_::Models_::Tree_Move.new(
          @expressive_stow.path,
          @project_path,
        )

        st = @expressive_stow.to_item_stream
        begin

          item = st.gets
          item or break
          uow.add item.file_relpath
          redo
        end while nil

        uow.execute(
          @filesystem,
          & @on_event_selectively )
      end
    end
  end
end
