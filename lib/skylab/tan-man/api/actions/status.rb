module Skylab::TanMan

  class API::Actions::Status < API::Action   # due for a refactor [#041]
    # (as it is it's a nifty proof of concept of complex event graphs,
    # but let's get that ee.push b.s out of here and make it headless)

    extend API::Action::Attribute_Adapter

    attribute :path, pathname: true, required: true

    emits :all, negative: :all, positive: :all, global: :all, local: :all,
      local_positive: [:local, :positive],
      local_negative: [:local, :negative],
      global_positive: [:global, :positive],
      global_negative: [:global, :negative],
      local_found: :local_positive,
      global_found: :global_positive

  protected

    def execute
      ee = []
      conf = service.config
      conf.ready? do |o|
        o.on_not_ready { |e| ee.push build_event(:local_negative, e) } # sketchy as all hell
        o.on_read_global = ->(oo) { oo.on_invalid { |e| ee.push build_event(:global_negative, e) } }
        o.on_read_local  = ->(oo) { oo.on_invalid { |e| ee.push build_event(:local_negative, e)  } }
      end
      unless ee.index { |e| e.is? :global }
        if conf.global.exist?
          ee.push build_event(:global_found,
            message: conf.global.pathname.pretty, pathname: conf.global.pathname)
        else
          ee.push build_event(:global_positive, 'not found')
        end
      end
      unless ee.index { |e| e.is? :local_negative }
        if conf.local.exist?
          ee.push build_event(:local_found,
            message: conf.local.pathname.pretty, pathname: conf.local.pathname)
        else
          ee.push build_event(:local_found,
            message: "#{conf.local.pathname.dirname.pretty}/", pathname: conf.local.pathname)
        end
      end
      ee
    end
  end
end
