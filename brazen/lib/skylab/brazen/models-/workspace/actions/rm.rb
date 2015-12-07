module Skylab::Brazen

  class Models_::Workspace

    class Actions::Rm < Home_::Action

      edit_entity_class(

        :branch_description, -> y do
          y << "remove a workspace"
        end,

        :flag, :property, :dry_run )

      def produce_result
        maybe_send_event :error, :not_yet_implemented do
          _ev = jbuild_not_OK_event_with :not_yet_implemented do |y, o|
            y << "removing workspaces is not yet implemented."
          end
        end
        UNABLE_
      end
    end
  end
end
