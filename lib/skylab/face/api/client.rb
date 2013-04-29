module Skylab::Face

  class API::Client

    # `API::Client` - experimental barebones impl.

    # `define_api_client` - this must be *not* monadic! (same block might
    # be re-run)

    def self.define_api_client &blk
      Face::Services::Headless::Plugin::Host.enhance self do
        services %i|
          has_instance
          set_new_valid_instance
          model
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

    #         ~ *experimentally* be a plugin host ~

    Services::Headless::Plugin::Host.enhance self do
      # nothing here - that is for your subclass to do
      # (half the reason we do this is for shenanigans)
    end

    #         ~ *experimental* default implementation of model mgr ~

    # include Face::Services::Headless::Plugin::Host::InstanceMethods

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

    # `set_new_valid_instance` - NOTE signuature might change

    def set_new_valid_instance( ( * model_ref_a ), init_blk, obj_if_yes, if_no )
      @model_manager.set_new_valid_instance model_ref_a, init_blk,
        obj_if_yes, if_no
    end

    #    ~ *experimental* API action normalization API [#fa-api-001:] ~
    #
    # give the API action a chance to run normalization (read: validation)
    # hooks before executing. note we want the specifics of this out of
    # the mode clients.

    # `normalize` - result is a tuple of `alt` (t|f) and `res`. if `alt`
    # is true, this inidcates that normalization failed for the API action
    # (and we have an "alternate" ending). running `execute` in such
    # circumstances will have undefined behavior and should not be done.
    # if the mode client want it, `res` is whatever result the API action
    # resulted in in respnose to the normalization failure (e.g it could
    # be an exit status code, depending on the API action).
    #
    # when `alt` is false this indicates that normalization *succeeded* for
    # the API action. `res` is undefined and should be disregarded. the mode
    # client should procede to call `execute` on the API action.
    #
    # NOTE the actual event wiring (as it pertain here to normalization)
    # is an area of active exploration that will almost certainly change
    # its implementation! you have been warned! (details: we sort of just
    # want to pass a `y` to write to, but we have this nice pub-sub thing
    # built out already..)
    #
    # (with the above said, please see [#fa-api-002] for more details)

    def normalize action
      y = action.instance_exec do  # emitting call below might be private
        Services::Basic::Yielder::Counting.new do |msg|
          normalization_failure_line msg
        end
      end
      action.normalize y, -> { false }, -> x { [ true, x ] }
    end
    public :normalize  # called by mode clients.
  end
end
