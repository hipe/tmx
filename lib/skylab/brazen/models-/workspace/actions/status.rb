module Skylab::Brazen

  class Models_::Workspace

  class Actions::Status < Brazen_::Model_::Action

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "get status of a workspace"
      end

      o :inflect, :verb, 'determine'

      o :is_promoted

      o :after, :init




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

    def produce_any_result
      a = to_even_iambic
      a.push :prop, self.class.properties.fetch( :path )
      a.push :delegate, self
      Brazen_::Models_::Workspace.new( @kernel ).produce_any_result_for_status a
    end

    def receive_workspace_event ev
      _ev = sign_event ev
      if ev.ok
        @client_adapter.receive_event _ev
      else
        @client_adapter.receive_positive_event _ev
      end
    end
  end
  end
end
