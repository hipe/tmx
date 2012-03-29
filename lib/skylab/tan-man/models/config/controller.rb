module Skylab::TanMan
  class Models::Config::Controller
    extend Bleeding::DelegatesTo
    include Api::AdaptiveStyle
    def add_remote name, url, resource_name
      require_relative '../remote'
      ready? or return false
      resource = config_singleton.send(resource_name)
      remote = Models::Remote.new.edit(name: name, url: url) { |o| o.on_error { |e| emit(e) } } # experimental pattern
      remote or return false
      name = remote.name # normalization maybe
      collection = resource.remotes
      if collection.detect { |r| name == r.name }
        emit(:info, "remote #{name.inspect} already exists.")
        true
      else
        collection.push remote
        write_resource resource
      end
    end
    delegates_to :runtime, :emit, :error
    def initialize runtime
      @remotes = nil
      @runtime = runtime
      @config_singleton = runtime.singletons.config
    end
    attr_reader :config_singleton
    def load_default_content resource
      resource.content_tree.tap do |o|
        o.prepend_comment '' # in reverse
        o.prepend_comment "parts of this file may have been generated and may be overwritten"
        o.prepend_comment "created #{Time.now.localtime} by tanman"
      end
    end
    def ready?
      config_singleton.ready? do |o|
        o.on_no_config_dir do |e|
          emit(:no_config_dir) { e.payload } # this line is critical, and confusing!
          # we need to re-emit a new event object with the same event type (symbol)
          # but a different graph @todo{after:.3} decide whether or not this is acceptable.
        end # !.. up to ..
        o.on_read_global = o.on_read_local = ->(oo) { oo.on_invalid { |e| error e } }
      end
    end
    def remotes
      @remotes ||= Models::Config::Remotes.new(config_singleton)
    end
    def remove_remote remote_name, resource_name
      remotes.remove(remote_name, resource_name, self)
    end
    attr_reader :runtime
    def write_resource resource
      if resource.exist? && resource.pathname_read == resource.content
        emit :info, "(config file didn't change.)"
        return true
      end
      if ! resource.exist?
        load_default_content(resource)
      end
      out = runtime.stdout # sucky
      resource.write do |o|
        o.on_error { |e| emit(e) ; return false }
        o.on_before_edit { |e| out.write(e.touch!.message) }
        o.on_before_create { |e| out.write(e.touch!.message) }
        b = ->(e){ out.puts(" .. done (#{e.touch!.bytes} bytes.)") }
        o.on_after_edit(&b)
        o.on_after_create(&b)
        o.on_all { |e| emit(:info, e.message) unless e.touched? }
      end
    end
  end
end

