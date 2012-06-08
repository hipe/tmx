module Skylab::TanMan
  class Api::Actions::Status < Api::Action
    attribute :path, pathname: true, required: true
    emits :all, negative: :all, positive: :all, global: :all, local: :all,
      local_positive: [:local, :positive], local_negative: [:local, :negative],
      global_positive: [:global, :positive], global_negative: [:global, :negative],
      local_found: :local_positive, global_found: :global_positive
    def execute
      ee = []
      sing = singletons.config
      sing.ready? do |o|
        o.on_not_ready { |e| ee.push build_event(:local_negative, e) } # sketchy as all hell
        o.on_read_global = ->(oo) { oo.on_invalid { |e| ee.push build_event(:global_negative, e) } }
        o.on_read_local  = ->(oo) { oo.on_invalid { |e| ee.push build_event(:local_negative, e)  } }
      end
      unless ee.index { |e| e.is? :global }
        if sing.global.exist?
          ee.push build_event(:global_found,
            message: sing.global.pathname.pretty, pathname: sing.global.pathname)
        else
          ee.push build_event(:global_positive, 'not found')
        end
      end
      unless ee.index { |e| e.is? :local_negative }
        if sing.local.exist?
          ee.push build_event(:local_found,
            message: sing.local.pathname.pretty, pathname: sing.local.pathname)
        else
          ee.push build_event(:local_found,
            message: "#{sing.local.pathname.dirname.pretty}/", pathname: sing.local.pathname)
        end
      end
      ee
    end
  end
end


