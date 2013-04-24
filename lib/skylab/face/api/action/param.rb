module Skylab::Face

  module API::Action::Param

    # this whole node if for experimenting in the automatic creation
    # of a set of meta-fields that can be recognized by the entity
    # library. tag your fields with these metafields and we can try
    # to make magic happen for you (#placeholder: [#fa-el-002])

  end

  class API::Action::Param::Flusher


    def self.[] param_a, host_mod  # assume param_a looks right structurally

      new( param_a, host_mod ).flush

    end

    METAFIELDS_BASE_ = [
      [ :field, :reflective ],
                # if the parameter is a field and not an option ([#fa-el-001])

      [ :option, :reflective ],
                # if the parameter is an option and not a field (idem)

      :required,  # entity library might interpret this to mean an assertion
               # for non-nil .. ( meaning is #experimental )

      # (currently, more detailed validation-type metafields are defined
      # as part of entity (model) libraries and not in this API facet..)

      # (trailing comma above is intentional and syntactically valid, but still
      # feels really weird to do without justifying it with this long comment)
    ].tap { |a| a.freeze.each( & :freeze ) }

    def initialize param_a, host_mod

      @flush = -> do

        Services::Basic::Field::Box.enhance host_mod do

          meta_fields( * METAFIELDS_BASE_ )

          fields( * param_a )

        end

        Services::Basic::Field::Reflection.enhance( host_mod ).with host_mod

        host_mod.field_box.names
      end
    end

    def flush
      @flush[ ]
    end
  end
end
