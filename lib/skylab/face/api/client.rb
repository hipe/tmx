module Skylab::Face

  class API::Client

    # `API::Client` - experimental barebones impl.

    def self.define_api_client &blk
      Face::Services::Headless::Plugin::Host.enhance self do
        services %i|
          has_instance
          set_instance
        |
        instance_exec( & blk )  # ERMAHGERD
      end
    end

    def build_action slug_str, param_h
      kls = api_actions_module.const_fetch slug_str
      kls.new self, param_h
    end
    public :build_action  # called e.g by another modality client

    Face::Services::ModuleAccessors.enhance self do

      private_methods do

        module_reader :api_actions_module, '../Actions' do
          extend MetaHell::Boxxy  # future i am sorry
        end

        module_reader :api_module, '..'

        module_reader :application_module, '../..'

        module_reader :models_module, '../../Models' do
          extend MetaHell::Boxxy
        end

      end
    end

    #         ~ *experimental* default implementation of model mgr ~

    include Face::Services::Headless::Plugin::Host::InstanceMethods

    # because we are overriding some of the above, include it now

    def model *x_a
      model_manager.aref x_a
    end
    public :model  # children call it

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

  private

    def model_manager
      @model_manager ||= begin
        Face::Model::Manager.new models_module, self
      end
    end

    # `has_instance` - called from host proxy - a service we expose to
    # model clients - note the signature change.

    def has_instance * model_ref_a
      @model_manager.has_instance model_ref_a
    end

    # `set_instance` - NOTE signuature might change

    def set_instance * model_ref_a, & init_blk
      @model_manager.set_instance model_ref_a, init_blk
    end
  end
end
