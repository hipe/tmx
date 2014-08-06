module Skylab::Brazen

  class Actions_::Status < Brazen_::Action_

    desc do |y|
      y << "get status of a workspace"
    end

    Brazen_::Entity_[ self, -> do

      o :environment, :non_negative_integer, :property, :MAX_NUM_DIRS

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
      Brazen_::Models_::Workspace.status( @verbose, @path, @MAX_NUM_DIRS,
        self.class.properties.fetch( :path ),
        Responses__.new( @client_adapter ) )
    end

    class Responses__

      def initialize client_adapter
        @client_adapter = client_adapter
      end

      def on_entity_event_channel_entity_structure ev
        @client_adapter.on_entity_event_channel_entity_structure ev ; nil
      end
    end
  end
end
