module Skylab::System

  class Services___::Filesystem

    Events_ = ::Module.new

    # for now: although this module has library scope its only purpose is to
    # hold generic, reusable event prototypes shared among sidesystems. the
    # module has been given library scope (and is not public) to future-proof
    # it so that we can turn it into a more sophisticated router if ever we
    # need to expose event prototypes that may live deeper in the system.

    Events_::Wrote = Callback_::Event.prototype_with(

      :wrote,

      :bytes, nil,
      :path, nil,
      :preterite_verb, 'wrote',
      :is_completion, true,
      :ok, true,

    ) do | y, o |

      y << "#{ o.preterite_verb } #{ pth o.path } (#{ o.bytes } bytes)"
    end
  end
end
