module Skylab::TanMan
  class Models::Config::Controller
    extend Bleeding::DelegatesTo
    include API::AdaptiveStyle
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
      resource.sexp.tap do |o|
        o.prepend_comment '' # in reverse
        o.prepend_comment "parts of this file may have been generated and may be overwritten"
        o.prepend_comment "created #{Time.now.localtime} by tanman"
      end
    end
    def ready?
      config_singleton.ready? do |o|
        o.on_no_config_dir { |e| emit(:no_config_dir, e) } # same payload, different graph
        o.on_read_global = o.on_read_local = ->(oo) { oo.on_invalid { |e| error e } }
      end
    end
    def remotes
      @remotes ||= Models::Config::Remotes.new(config_singleton)
    end
    def remove_remote remote_name, resource_name
      remotes.remove(remote_name, resource_name) do |o|
        o.on_write = ->(e) { write_resource e.touch!.resource }
        o.on_all = ->(e) { emit(e) unless e.touched? }
        o.on_remote_not_found do |e|
          error "couldn't find a remote named #{e.remote_name.inspect}"
          a = remotes.map { |r| pre r.name }
          rc = e.resources_count
          available = [
            "#{s a, :no}known remote#{s a} #{s a, :is} #{oxford_comma(a, ' and ')}".strip,
            " in #{s rc, :this}#{" #{rc}" unless 1==rc} searched config resource#{s rc}."
          ].join('')
          e.touch!
          emit(:info, available)
        end
      end
    end
    attr_reader :runtime
    def write_resource resource
      if resource.exist? && resource.pathname.read == resource.content
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
    delegates_to :runtime, :text_styler
  end
end

