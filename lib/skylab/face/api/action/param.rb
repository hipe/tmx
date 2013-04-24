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
      :field,  # if the parameter is a field and not an option ([#fa-el-001])
      :option, # if the parameter is an option and not a field (idem)
      :list,   # if the value when set is enumerable (used in validation
               # handlers to conditionally handle the parameter as such).
      :required,  # entity library might interpret this to mean an assertion
               # for non-nil .. ( meaning is #experimental )
      [ :rx, :property ],  # indicate a regex for validation
      [ :rx_fail_predicate_tmpl, :property ],  # a predicate string
               # about a regex match failure. the template can use
               # {{ick}} to substitue the provided string
      :noop,   # you can use this if you want to meta-tag the field
               # about the fact that you accept the parameter but are not
               # (yet?) doing anything with it (but the entity libary
               # certainly assigns this no special meaning).
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
