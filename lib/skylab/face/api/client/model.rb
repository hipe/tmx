module Skylab::Face

  module API::Client::Model

    # the API Client having model facilities is opt-in, and for now activated
    # by calling the below method `[]` (`enhance` will be added when needed.)
    # this is designed to be re-affirmable - that is, each additional time
    # the below logic is run on the same API client class, it should have no
    # additional side-effects.

    def self.[] host
      Library_::Headless::Plugin::Host.enhance host do
        services( * %i|
          has_model_instance
          set_new_valid_model_instance
          model
        | )
        host.send :include, API::Client::Model::InstanceMethods  # wedged in here
          # in case we override above, and get overridden below
      end
      nil
    end
  end

  module API::Client::Model::InstanceMethods

    MetaHell::Module::Accessors.enhance( self ).
        private_module_reader( :models_module, '../../Models' ) do
      MetaHell::Boxxy[ self ]  # re-affirmable
    end

    # `plugin_host_proxy_aref` - part of our underlying plugin API -
    # this is what implements calls to `host[]` from e.g inside the
    # models.
    #
    # (note that `_plugin_story` is ignored because we do not validate
    # access - we do not require that plugins (e.g models) declare what
    # models they want to access, with the reasoning that it will be
    # clunky to need to list every name of every model that every other
    # model wants access to, but this may change.
    #
    # on this subject, this is related to why we don't have pretty
    # accessor methods for the model names, (e.g we have `host[:config]`, not
    # `host.config`) so we do not need to eager load our entire model.)

    def plugin_host_proxy_aref x_a, _plugin_story
      model_manager.aref x_a
    end

    # `has_model_instance` - called from host proxy - a service we expose to
    # model clients - note the signature change.

    def has_model_instance * model_ref_a
      @model_manager.has_instance model_ref_a
    end

    # `set_new_valid_model_instance` - NOTE signuature might change
    # this is a service used by clients that employ the face API model API

    def set_new_valid_model_instance( ( * model_ref_a ), init_blk, obj_if_yes, if_no )
      @model_manager.set_new_valid_instance model_ref_a, init_blk,
        obj_if_yes, if_no
    end

  private

    def model *x_a
      ::Symbol === x_a.first or fail 'where'
      model_manager.aref x_a
    end

    def model_manager
      @model_manager ||= begin
        Face::Model::Manager.new models_module, self
      end
    end
  end
end
