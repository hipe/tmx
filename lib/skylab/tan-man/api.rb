module Skylab::TanMan

  module API
    # after this file completes loading, this class will get sexed by
    # recursive autoloader.
  end

  module API::Emitter             # [#046] may be deprecated
    def self.new *a
      e = PubSub::Emitter.new(* a )
      e.event_factory API::Event::Factory
      e
    end
  end

  class << API

    # For no good reason, API (the module) is the home of low-level config.

    extend MetaHell::Formal::Attribute::Definer

    include Core::Attribute::Reflection::InstanceMethods

    meta_attribute(* Core::MetaAttributes[ :default, :proc ] )

    alias_method :attribute_definer, :singleton_class # @experimental:
      # this means that the objects will no longer use their class
      # as the attribute_definer

    attribute :default_starter_file, default: 'holy-smack.dot'

    attribute :global_conf_path, proc: true,
                default: -> do
                  Headless::System.system.any_home_directory_pathname.
                    join( 'tanman-config' ).to_s
                end

    attribute :local_conf_config_name, default: 'config'

    attribute :local_conf_dirname, default: '.tanman'

    attribute :local_conf_maxdepth, default: nil # meaningful (and didactic) nil

    attribute :local_conf_startpath, proc: true, default: ->{ ::Pathname.pwd }

    attr_accessor :debug          # set to $s-tderr, for e.g

  end

  API.set_defaults_if_nil!

end
