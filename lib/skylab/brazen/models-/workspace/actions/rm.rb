module Skylab::Brazen

  class Models_::Workspace

    class Actions::Rm < Brazen_::Model_::Action

      Brazen_::Model_::Entity[ self, -> do

        o :desc, -> y do
          y << "remove a workspace"
        end
      end ]
    end
  end
end
