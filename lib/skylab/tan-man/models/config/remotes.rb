module Skylab::TanMan
  # distinct from a remote collection which is all the remotes in one file
  # this is a higher level enumerator of all the remotes across all resources
  class Models::Config::Remotes < ::Enumerator
    attr_reader :config_singleton
    def initialize config_singleton, &block
      @num_resources_seen = 0
      @config_singleton = config_singleton
      block ||= ->(y) do
        seen = {}
        @num_resources_seen = 0
        self.config_singleton.resources.each do |resource|
          @num_resources_seen += 1
          resource.remotes.each do |remote|
            seen[remote.name] ||= begin
              y << remote
              true
            end
          end
        end
      end
      super(&block)
    end
    attr_reader :num_resources_seen
    class OnRemove < Api::Emitter.new(:all, error: :all, remote_not_found: :error)
      attr_accessor :on_all
      attr_accessor :on_write
    end
    def remove remote_name, resource_name, &b
      e = OnRemove.new(b)
      if resource_name
        config_singleton.send(resource_name).tap do |r|
          remotes = r.remotes
          resources_count = 1
        end
      else
        remotes = self
        resources_count = config_singleton.resources_count
      end
      if remote = remotes.detect { |r| remote_name == r.name }
        remote.resource.remotes.remove(remote) do |o|
          o.on_write(& e.on_write)
          o.on_all(& e.on_all)
        end
      else
        e.emit(:remote_not_found,
          remotes:         remotes,
          remote_name:     remote_name,
          resources_count: resources_count
        )
      end
    end
  end
end

