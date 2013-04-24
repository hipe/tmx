module Skylab::Cull

  module API::Actions::DataSource

  end

  class API::Actions::DataSource::List < API::Action

    params  # no params

    services :model

    emits :payload_line, couldnt: :entity_event

    def execute
      host.model( :data, :sources ).
        list method( :payload_line ), method( :couldnt )
    end
  end

  class API::Actions::DataSource::Add < API::Action

    # #experimental below meta-fields defined at `Face::API::Action::Param`
    # (note that the meta-fields are only used for packing and unpacking
    # requests, and not for validation here. that happens in the model)

    params [ :name,       :field  ],
           [ :url,        :field  ],
           [ :tag_a,      :field  ],
           [ :is_dry_run, :option ]

    services :model

    emits  :before, :after, :all,
      could: :entity_event, couldnt: :entity_event

    def execute
      field_h, opt_h = pack_fields_and_options
      coll = host.model :data, :sources
      coll.add field_h, opt_h,
        could: method( :could ),
        couldnt: method( :couldnt ),
        before: method( :before ),
        after: method( :after ),
        all: method( :all ),
        pth: pth
    end
  end
end
