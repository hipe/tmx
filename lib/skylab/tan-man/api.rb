module Skylab::TanMan


  module API
    class RuntimeError < ::RuntimeError # just for fun
    end
  end



  module API::Emitter             # [#046] may be deprecated
    def self.new *a
      e = PubSub::Emitter.new(* a)
      e.event_class API::Event
      e
    end
  end



  class << API

    extend Porcelain::Attribute::Definer

    include Core::Attribute::Reflection::InstanceMethods

    meta_attribute(* Core::MetaAttributes[ :default, :proc ] )

    alias_method :attribute_definer, :singleton_class # @experimental:
      # this means that the objects will no longer use their class
      # as the attribute_definer

    attribute :global_conf_path,
                 proc: true, default: ->{ "#{ ENV['HOME'] }/.tanman-config" }

    attribute :local_conf_config_name, default: 'config'

    attribute :local_conf_dirname, default: '.tanman'

    attribute :local_conf_maxdepth, default: nil # meaningful (and didactic) nil

    attribute :local_conf_startpath,
                 proc: true, default: ->{ ::Skylab::Face::MyPathname.pwd }

    attr_accessor :debug          # set to $stderr, for e.g

  end

  API.set_defaults_if_nil!

end
