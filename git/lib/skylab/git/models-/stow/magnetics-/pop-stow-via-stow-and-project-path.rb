module Skylab::Git

  class Models_::Stow

    class Magnetics_::PopStow_via_Stow_and_ProjectPath < Common_::MagneticBySimpleModel  # 1x

      attr_accessor(
        :expressive_stow,
        :filesystem,
        :listener,
        :project_path,
      )

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

        uow.execute @filesystem, & @listener
      end

      # ==
      # ==
    end
  end
end
