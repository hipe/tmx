module Skylab::System

  module Filesystem

    Events = ::Module.new

    Events::Wrote = Common_::Event.prototype_with(
      # (#[#032.2] tracks other event classes like this)

      :wrote,

      :bytes, nil,
      :path, nil,
      :is_dry, false,
      :preterite_verb, 'wrote',
      :is_completion, true,
      :ok, true,

    ) do | y, o |

      if o.is_dry
        _dry = ' dry'
      end

      path = o.path
      if path
        y << "#{ o.preterite_verb } #{ pth path } (#{ o.bytes }#{ _dry } bytes)"
      else
        y << "#{ o.preterite_verb } #{ o.bytes }#{ _dry } bytes"
      end
    end
  end
end
