module Skylab::Cull

  class API::Actions::Init < API::Action

    params :path, :is_verbose, :is_dry_run

    emits :before, :after, exists_event: :model_event, info: :all

    def execute
      model( :configs ).create(
        @path || ::ENV[ 'HOME' ] || '.',
        @is_dry_run,
        pth,
        method( :exists_event ),
        method( :before ),
        method( :after ),
        method( :all )
      )
    end
  end
end
