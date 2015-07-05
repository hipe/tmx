module Skylab::Git

  class Models_::Stow

    class Sessions_::Save

      attr_accessor(
        :filesystem,
        :stow_name,
        :stows_collection,
        :system_conduit,
        :versioned_directory,
      )

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      def execute

        _ok = __resolve_valid_name
        _ok &&= __money
      end

      def __resolve_valid_name

        id = @stows_collection.produce_available_identifier(
          @stow_name,
          & @on_event_selectively )

        if id
          @_stow_ID = id
          ACHIEVED_
        else
          id
        end
      end

      def __money

        uow = Stow_::Models_::Tree_Move.new(
          @versioned_directory.project_path,
          @_stow_ID.path,
        )

        st = @versioned_directory.to_entity_stream
        begin
          relpath = st.gets
          relpath or break
          uow.add relpath
          redo
        end while nil

        uow.execute(
          :do_not_prune,
          @filesystem,
          & @on_event_selectively )
      end
    end
  end
end
