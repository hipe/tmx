module Skylab::Zerk

  module API

    # attempt to realize a zerk-compatible [ac] ACS as an "API", so that
    # its underlying operations can be invoked directly without needing to
    # go thru a UI.
    #
    # this is intended to be useful if you want to expose your zerk-assisted
    # application as a callable library.  this allows you (for example) to
    # test your application functionally by being able to invoke your
    # operations "more directly" without having the overhead, noise and
    # extra moving parts of a full UI.
    #
    # (more notes would go in [#002])

    class << self

      def call args, acs, & pp

        Require_ACS_[]

        if ! pp
          pp = ACS_.handler_builder_for acs
        end

        o = Here_::Invocation___.new args, acs, & pp
        bc = o.execute
        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          bc
        end
      end
    end  # >>

    Here_ = self
  end
end
