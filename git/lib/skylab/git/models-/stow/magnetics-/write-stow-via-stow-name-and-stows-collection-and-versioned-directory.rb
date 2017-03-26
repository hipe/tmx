module Skylab::Git

  class Models_::Stow

    class Magnetics_::WriteStow_via_StowName_and_StowsCollection_and_VersionedDirectory < Common_::MagneticBySimpleModel  # 1x

      attr_accessor(
        :filesystem,
        :listener,
        :stow_name,
        :stows_collection,
        :system_conduit,
        :versioned_directory,
      )

      def execute

        _ok = __resolve_valid_name
        _ok &&= __money
      end

      def __resolve_valid_name

        _ = @stows_collection.produce_available_identifier(
          @stow_name,
          & @listener )

        _store :@_stow_ID, _
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
          & @listener )
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # ==
      # ==
    end
  end
end
