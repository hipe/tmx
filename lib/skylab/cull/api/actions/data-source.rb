module Skylab::Cull

  module API::Actions::DataSource

  end

  class API::Actions::DataSource::List < API::Action

    params  # no params

    emits :payload_line, error_event: :model_event

    def execute
      @client.model( :data, :sources ).
        list method( :payload_line ), method( :error_event )
    end
  end

  class API::Actions::DataSource::Add < API::Action

    # #experimental below meta-fields defined at `Face::API::Action::Param`
    # (note that the meta-fields are onoly used for packing and unpacking
    # requests, and not for validation here. that happens in the model)

    params [ :name,       :field  ],
           [ :url,        :field  ],
           [ :tag_a,      :field  ],
           [ :is_dry_run, :option ],
           [ :be_verbose, :option ]

    emits error_event: :model_event, info_event: :model_event

    def execute
      h = { field: { }, option: { } }
      ks = h.keys
      fields_bound_to_ivars.each do |bf|
        ks.each do |k|
          if bf.field[ k ]
            h.fetch( k )[ bf.field.normalized_name ] = bf.value
          end
        end
      end
      @client.model( :data, :sources ).add h[:field], h[:option],
        method( :error_event ), method( :info_event )
    end
  end
end
