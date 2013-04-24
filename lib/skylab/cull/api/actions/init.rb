module Skylab::Cull

  class API::Actions::Init < API::Action

    params [ :path, :field, :required ],
           [ :be_verbose, :noop ],
           [ :is_dry_run, :option ]

    services :configs

    emits :before, :after, exists_event: :model_event, info: :all

    def execute
      f_h, o_h = pack_fields_and_options
      host.configs.create f_h, o_h,
        exists: method( :exists_event ),
        before: method( :before ),
        after: method( :after ),
        all: method( :all ),
        pth: pth
    end
  end
end
