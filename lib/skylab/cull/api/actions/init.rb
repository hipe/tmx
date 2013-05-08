module Skylab::Cull

  class API::Actions::Init < API::Action

    params [ :path, :field, :required ],
           [ :is_dry_run, :option ]

    services :configs, [ :pth, :ingest ]

    emits :before, :after, :all, couldnt_event: :entity_event

    def execute
      f_h, o_h = pack_fields_and_options
      host.configs.create f_h, o_h,
        couldnt: method( :couldnt_event ),
        before: method( :before ),
        after: method( :after ),
        all: method( :all ),
        pth: @pth
    end
  end
end
