module Skylab::Tmx::Modules::Bleed::Api
  class Actions::Init < Action
    emits head: :all, tail: :all
    def invoke
      if config.exist?
        emit :info, "exists, won't overwrite: #{config.pretty}"
        return nil
      end
      root = ::Skylab::ROOT.to_s.sub(%r{^#{Regexp.escape ENV['HOME']}/}, '~/')
      config['bleed'] ||= {} # create the section called [bleed]
      config['bleed']['root'] = root
      config.write do |o|
        o.on_before   { |e| emit(:head, "config: #{e.message}") ; e.touch! }
        o.on_after    { |e| emit(:tail, " .. done (wrote #{e.bytes} bytes).") ; e.touch! }
        o.on_all      { |e| emit(:info, "handle me-->#{e.type}<-->#{e.message}" ) unless e.touched? }
      end
    end
  end
end

