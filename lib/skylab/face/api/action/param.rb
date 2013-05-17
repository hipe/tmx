module Skylab::Face

  module API::Action::Param

    # this whole node if for experimenting in the automatic creation of a set
    # of meta-fields that can be recognized by the entity library. tag your
    # fields with these metafields and we can try to make magic happen for you
    #
    # [#fa-014] (for now under the entity node)

    METAFIELDS_ = [

      [ :field, :reflective ],
                # if the parameter is a field and not an option

      [ :option, :reflective ],
                # if the parameter is an option and not a field (idem)

      # [ :a-rity, :property ], # [#fa-024]  # #todo:during:arity
      [ :desc, :property ], # [#fa-030]

      :required,  # entity library might interpret this to mean an assertion
               # for non-nil .. ( meaning is #experimental )

      # (currently, more detailed validation-type metafields are defined
      # as part of entity (model) libraries and not in this API facet..)

      [ :normalizer, :property ], # [#fa-021]

      # (trailing comma above is intentional and syntactically valid, but still
      # feels really weird to do without justifying it with this long comment)
    ].tap { |a| a.freeze.each( & :freeze ) }

    # `self.[]` - enhance the API::Action class with this facet.
    # fulfill [#fa-026]. assumes it is behind a module mutex.
    # assumes `param_a` looks right structurally.

    def self.[] host_mod, param_a
      Services::Basic::Field::Box.enhance host_mod do
        # extend_field_class_with -> { API::Action::Param::Field_IMs_ }
        meta_fields( * API::Action::Param::METAFIELDS_ )
        fields( * param_a )
      end
      Services::Basic::Field::Reflection.enhance( host_mod ).with host_mod
      host_mod.send :include, API::Action::Param::InstanceMethods
      nil
    end
  end

  module API::Action::Param::Field_IMs_

    -> do
      # implement the idea of a required field by deriving the boolean
      # of required-ness from the argument arity [#fa-024]
      is_req_h = {
        zero: false,
        zero_or_one: false,
        zero_or_more: false,
        one: true,
        one_or_more: true,
      }
      define_method :is_required do
        if has_arity
          is_req_h.fetch @arity_value
        else
          true  # if e.g a plain simple inline with some complex guys
        end
      end
    end
  end

  module API::Action::Param::InstanceMethods

    def has_param_facet
      true
    end
    # public. fulfill [#fa-027].

    # `pack_fields_and_options` - #experimentally many methods in the
    # entity library take the "sacred four" parameters [#fa-012].
    # freqently requests coming in from the client will munge the
    # two namespaces (one of business-level fields, (e.g "email") and the
    # other of controller-level options (e.g `verbose`), however the
    # entity library insists on more rigidity and structure than this.

    # experimentally your API actions defines parameters (a.k.a fields)
    # using meta-fields that tag meta-info about each field, e.g whether
    # the field is a "field" field or an "option" field.

    # So, of each field in this field box reflector, along the categories of:
    #   `field` and `option`,
    # when each field falls into one (or more wtf) of these two categories
    # one hash is made for each category, with its names being the field
    # name and its values being the field's values.
    # result is always an array of two hashes.

    -> do
      a = %i( field option )
      define_method :pack_fields_and_options do
        h = ::Hash[ a.map { |k| [ k, { } ] } ]
        ks = h.keys
        fields_bound_to_ivars.each do |bf|
          ks.each do |k|
            if bf.field[ k ]
              h.fetch( k )[ bf.field.normalized_name ] = bf.value
            end
          end
        end
        a.map { |k| h.fetch k }
      end
    end.call
  end
end
