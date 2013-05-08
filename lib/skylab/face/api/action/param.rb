module Skylab::Face

  module API::Action::Param

    # this whole node if for experimenting in the automatic creation of a set
    # of meta-fields that can be recognized by the entity library. tag your
    # fields with these metafields and we can try to make magic happen for you
    # (#placeholder: [#fa-el-002])

    METAFIELDS_ = [

      [ :field, :reflective ],
                # if the parameter is a field and not an option ([#fa-el-001])

      [ :option, :reflective ],
                # if the parameter is an option and not a field (idem)

      :required,  # entity library might interpret this to mean an assertion
               # for non-nil .. ( meaning is #experimental )

      # (currently, more detailed validation-type metafields are defined
      # as part of entity (model) libraries and not in this API facet..)

      [ :normalizer, :property ],

      # (trailing comma above is intentional and syntactically valid, but still
      # feels really weird to do without justifying it with this long comment)
    ].tap { |a| a.freeze.each( & :freeze ) }

  end

  class API::Action::Param::Flusher


    def self.[] param_a, host_mod  # assume param_a looks right structurally

      new( param_a, host_mod ).flush

    end

    def initialize param_a, host_mod

      @flush = -> do

        Services::Basic::Field::Box.enhance host_mod do

          meta_fields( * API::Action::Param::METAFIELDS_ )

          fields( * param_a )

        end

        Services::Basic::Field::Reflection.enhance( host_mod ).with host_mod

        host_mod.send :include, API::Action::Param::InstanceMethods

        nil
      end
    end

    def flush
      @flush[ ]
    end
  end

  module API::Action::Param::InstanceMethods

    # `pack_fields_and_options` - #experimentally many methods in the
    # entity library take the "sacred four" parameters [#fa-el-001].
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
