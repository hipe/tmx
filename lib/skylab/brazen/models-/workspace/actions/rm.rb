module Skylab::Brazen

  class Models_::Workspace

    class Actions::Rm < Brazen_::Model_::Action

      Brazen_::Model_::Entity.call self do

        o :desc, -> y do
          y << "remove a workspace"
        end

        o :flag, :property, :dry_run
      end

      def produce_any_result
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
