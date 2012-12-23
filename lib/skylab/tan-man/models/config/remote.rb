module Skylab::TanMan

  # a higher-level collection controller #experimental-ly subclassing
  # ::Enumerator, for enumerating all of the remote entries across
  # all of the config resources.



  module Models::Config::Remote
    # empty namespace, all contained within this file for now
  end


  class Models::Config::Remote::Collection < ::Enumerator

    alias_method :config_original_initialize, :initialize # ick, enumerator
                                  # subclients will be annoying unless we are
                                  # less aggressive somewhere

    include Core::SubClient::InstanceMethods # don't need m.m yet

    # below line is kept for #posterity as the #birth of the sub-client pattern
    # there is some kind of fun @smell here. What we want is shared controller logic
    def get name, e
      result = nil
      begin
        name = name.to_s
        result = detect { |r| name == r.name }
        result and break
        a = map(&:name).uniq.map { |n| kbd n }
        msg = "Remote #{ name.inspect } not found. #{ s a, :no }known #{
          } remote#{ s } #{ s :is } #{ or_ a }.".strip.capitalize
        e.emit :remote_not_found,
          remote_name: name,
          known_names: a,
          message: msg
        result = nil
      end while nil
      result
    end

    def initialize request_client, &block
      _headless_sub_client_init! request_client
      @num_resources_seen = 0
      block ||= -> y do
        seen = { }
        @num_resources_seen = 0
        services.config.resources.each do |resource|
          @num_resources_seen += 1
          resource.remotes.each do |remote|
            seen[remote.name] ||= begin
              y << remote
              true
            end
          end
        end
      end
      config_original_initialize(& block)
    end

    attr_reader :num_resources_seen

    on_remove =
      ::Class.new( API::Emitter.new error: :all, remote_not_found: :error )
    on_remove.class_eval do
      attr_accessor :on_all
      attr_accessor :on_write
    end

    define_method :remove do |remote_name, resource_name, &b|
      e = on_remove.new b
      if resource_name
        resource = services.config.send resource_name # #todo
        remotes = resource.remotes
        resources_count = 1
      else
        remotes = self
        resources_count = services.config.resources_count
      end
      remote = remotes.detect { |r| remote_name == r.name }
      if remote
        remote.resource.remotes.remove remote do |o|
          o.on_write(& e.on_write)
          o.on_all(& e.on_all)
        end
      else
        e.emit :remote_not_found,
          remotes:         remotes,
          remote_name:     remote_name,
          resources_count: resources_count
        nil
      end
    end
  end
end
