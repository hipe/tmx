module Skylab::Cull

  class API::Actions::Init < API::Action

    meta_params :cfg

    params [ :directory, :cfg,
                 :desc, -> y do
                   y << "where to write #{ config_filename } #{
                     }(default: #{ pth[ config_default_init_directory ] })"
                 end,
                 :default, -> { config_default_init_directory } ],
           [ :is_dry_run,
                 :arity, :zero_or_one,
                 :argument_arity, :zero,
                 :desc, "dry run." ]

    services :configs, [ :pth, :ivar ], :config_default_init_directory

    listeners_digraph :before, :after, :all, couldnt_event: :entity_event

    cfg

    def execute
      c_h, o_h = unpack_params :cfg, true
      configs.create c_h, o_h,
        couldnt: method( :couldnt_event ),
        before: method( :before ),
        after: method( :after ),
        all: method( :all )
    end
  end
end
