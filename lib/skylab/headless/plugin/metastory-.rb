module Skylab::Headless

  class Plugin::Metastory_

    METHOD_ = -> do  # (context of below is the particular client class!)
      if const_defined? :PLUGIN_METASTORY_, false
        const_get :PLUGIN_METASTORY_, false
      else
        const_set :PLUGIN_METASTORY_, Plugin::Metastory_.new( self )
      end
    end

    def initialize klass
      @klass = klass
    end

    def is_host
      @klass.const_defined? :Plugin_Host_Metaservices_, false
    end

    def is_plugin
      @klass.const_defined? :Plugin_Metaservices_, false
    end
  end
end
