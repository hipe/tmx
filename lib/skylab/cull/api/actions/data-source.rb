module Skylab::Cull

  module API::Actions::DataSource

  end

  class API::Actions::DataSource::List < API::Action

    params  # no params

    services :model

    emits :payload_line, error_event: :model_event

    def execute
      host.model( :data, :sources ).
        list method( :payload_line ), method( :error_event )
    end
  end

  class API::Actions::DataSource::Add < API::Action


    # #experimental below meta-fields defined at `Face::API::Action::Param`
    # (note that the meta-fields are only used for packing and unpacking
    # requests, and not for validation here. that happens in the model)

    params [ :name,       :field  ],
           [ :url,        :field  ],
           [ :tag_a,      :field  ],
           [ :is_dry_run, :option ],
           [ :be_verbose, :option ]

    services :model

    emits error_event: :model_event, info_event: :model_event

    def execute
      field_h, opt_h = pack_fields_and_options
      coll = host.model :data, :sources
      coll.add field_h, opt_h, method( :error_event ), method( :info_event )
    end
  end
end
