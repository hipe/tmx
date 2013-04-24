module Skylab::Face

  module API::Action::Param
  end

  class API::Action::Param::Flusher


    def self.[] param_a, host_mod  # assume param_a looks right structurally

      new( param_a, host_mod ).flush

    end

    def initialize param_a, host_mod

      @flush = -> do

        Services::Basic::Field::Box.enhance host_mod do

          # experimental here
          #

          meta_fields(
            :field,  # if the parameter is a field and not an option
            :option, # if the parameter is an option and not a field
            :list,   # if the value when set is enumerable
            [ :rx, :property ],  # indicate a regex for validation
            [ :rx_fail_predicate_tmpl, :property]  # a predicate string
                     # about a regex match failure. the template can use
                     # {{ick}} to substitue the provided string
          )

          fields( * param_a )

        end

        Services::Basic::Field::Reflection.enhance(host_mod).with host_mod

        host_mod.field_box.names
      end
    end

    def flush
      @flush[ ]
    end
  end
end
