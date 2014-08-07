module Skylab::Brazen

  class Actions_::Init < Brazen_::Action_

    desc do |y|
      y << "init a #{ highlight '<workspace>' }"
      y << "this is the second line of the init description"
    end

    Brazen_::Entity_[ self, -> do

      o :flag, :property, :verbose

      o :default, '.',
        :description, -> y do
          y << "the directory to init"
        end,
        :property, :path

    end ]

    def execute
      Brazen_::Models_::Workspace.init @verbose, @path,
       self.class.properties.fetch( :path ),
        Responses__.new( @client_adapter )
    end

    class Responses__

      def initialize c_a
        @client_adapter = c_a
      end

      def on_entity_event_channel_entity_structure ev
        @client_adapter.on_entity_event_channel_entity_structure ev ; nil
      end
    end
  end
end
