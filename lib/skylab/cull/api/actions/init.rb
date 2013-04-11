module Skylab::Cull

  class API::Actions::Init < API::Action

    params :path, :is_verbose, :is_dry_run

    emits :before, :after, exists_event: :model_event, info: :all

    def execute
      model( :configs ).init(
        @path || ::ENV[ 'HOME' ] || '.',
        @is_dry_run,
        pth,
        method( :exists_event ),
        method( :before ),
        method( :after ),
        method( :info ),
        method( :all )
      )
    end
  end
end
