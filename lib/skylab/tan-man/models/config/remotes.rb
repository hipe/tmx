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
    def remove remote_name, resource_name, controller
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
          o.on_write { |e| controller.write_resource e.touch!.resource }
          o.on_all { |e| controller.emit(e) unless e.touched? }
        end
      else
        # all of this slop etc @todo{at:.2}.  we "borrow" controller just to make a pretty message
        controller.instance_eval do
          a = remotes.map { |r| "#{pre r.name}" } ; rc = resources_count
          error "couldn't find a remote named #{remote_name.inspect}"
          emit(:info, [
            "#{s a, :no}known remote#{s a} #{s a, :is} #{oxford_comma(a, ' and ')}".strip,
            " in #{s rc, :this}#{" #{rc}" unless 1==rc} searched config resource#{s rc}."
          ].join(''))
        end
      end
    end
  end
end

