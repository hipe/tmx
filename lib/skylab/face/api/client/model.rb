module Skylab::Face

  module API::Client::Model  # read [#057] the API client model .. #intro

    def self.[] host
      LIB_.plugin_lib::Host.enhance host do
        services( * %i(
          has_model_instance
          set_new_valid_model_instance
          model
        ) )
        host.send :include, API::Client::Model::InstanceMethods  # wedged in here
          # in case we override above, and get overridden below
      end ; nil
    end
  end

  module API::Client::Model::InstanceMethods

    LIB_.module_accessors( self ).
        private_module_reader( :models_module, '../../Models' ) do
      respond_to? :dir_pathname or Autoloader_[ self, :boxxy ]
    end

    def plugin_host_proxy_aref x_a, _plugin_story  # #storypoint-30
      model_manager.aref x_a
    end

    def has_model_instance * model_ref_a  # #storyoint-35
      @model_manager.has_instance model_ref_a
    end

    def set_new_valid_model_instance( ( * model_ref_a ), init_blk, obj_if_yes, if_no )
      @model_manager.set_new_valid_instance model_ref_a, init_blk,
        obj_if_yes, if_no
    end  # #storypoint-40

  private

    def model *x_a
      ::Symbol === x_a.first or fail 'where'
      model_manager.aref x_a
    end

    def model_manager
      @model_manager ||= begin
        Face_::Model::Manager.new models_module, self
      end
    end
  end
end
