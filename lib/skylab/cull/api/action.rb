module Skylab::Cull

  class API::Action < Face::API::Action

    attr_reader :be_verbose  # accessed by common `api` implementation

    taxonomic_streams  # none. (but this allows us to check for unhandled
    # non-taxonomic streams - sorta future-proofing it.)

    def self.cfg
      include Cfg_IMs_
      nil
    end

    module Cfg_IMs_
    private
      def configs
        @plugin_host_services[ :configs ]  # or u can use im of same nm as ivar
      end
      def config_default_init_directory
        @plugin_host_services[ :config_default_init_directory ]
      end
    end
  end
end
