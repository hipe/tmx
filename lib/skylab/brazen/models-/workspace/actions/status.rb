module Skylab::Brazen

  class Models_::Workspace

  class Actions::Status < Brazen_::Model_::Action

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "get status of a workspace"
      end

      o :inflect, :verb, 'determine'

      o :is_promoted




      o :environment, :non_negative_integer,
        :description, -> y do
          y << "how far up do we look?"
        end,
        :property, :MAX_NUM_DIRS


      o :flag, :property, :verbose


      o :default, '.',
        :description, "the location of the workspace",
        :description, -> y do
          y << "it's #{ highlight 'really' } neat"
        end,
        :required,
        :property, :path

    end ]

    def execute
      a = to_even_iambic
      a.push :prop, self.class.properties.fetch( :path )
      a.push :listener, listener
      Brazen_::Models_::Workspace.status a
    end

    class Listener < Brazen_::Entity::Event::Listener_X

      def on_workspace_event ev
        _ev = sign_event ev
        @listener.on_positive_event _ev
      end
    end
  end
  end
end
