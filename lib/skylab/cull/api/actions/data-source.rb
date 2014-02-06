module Skylab::Cull

  module API::Actions::DataSource

  end

  class API::Actions::DataSource::List < API::Action

    params  # no params

    services :model, [ :pth, :ivar ]

    listeners_digraph :payload_line, couldnt: :entity_event

    def execute
      model( :data, :sources ).
        list method( :payload_line ), method( :couldnt )
    end
  end

  class API::Actions::DataSource::Add < API::Action

    # #experimental below meta-fields defined at `Face::API::Action::Param`
    # (note that the meta-fields are only used for packing and unpacking
    # requests, and not for validation here. that happens in the model)

    meta_params :ds

    params [ :name,       :arity, :one, :ds ],
           [ :url,        :arity, :one, :ds ],
           [ :tag_a,      :arity, :zero_or_more, :ds ],
           [ :is_dry_run, :arity, :zero_or_one, :argument_arity, :zero ]

    services :model, [ :pth, :ivar ]

    listeners_digraph :before, :after, :all,
      could: :entity_event, couldnt: :entity_event

    def execute
      field_h, opt_h = unpack_params :ds, true
      coll = model :data, :sources
      coll.add field_h, opt_h,
        could: method( :could ),
        couldnt: method( :couldnt ),
        before: method( :before ),
        after: method( :after ),
        all: method( :all ),
        pth: @pth
    end
  end
end
