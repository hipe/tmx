module Skylab::Brazen

  class Models_::Workspace

  class Actions::Init < Brazen_::Model_::Action

    Brazen_::Model_::Entity[ self, -> do

      o :desc, -> y do
        y << "init a #{ highlight '<workspace>' }"
        y << "this is the second line of the init description"
      end

      o :inflect, :noun, :lemma, :with_lemma, 'workspace'

      o :is_promoted




      o :flag, :property, :dry_run


      o :flag, :property, :verbose


      o :default, '.',
        :description, -> y do
          y << "the directory to init"
        end,
        :property, :path  # even though not alphabetical, leave at end

    end ]

    def execute
      a = to_even_iambic
      a.push :prop, self.class.properties.fetch( :path )
      a.push :client, @client_adapter
      a.push :listener, self
      Brazen_::Models_::Workspace.new( @kernel ).edit a
    end

    def receive_workspace_event ev
      _ev = sign_event ev
      @client_adapter.receive_event _ev
    end
  end
  end
end
