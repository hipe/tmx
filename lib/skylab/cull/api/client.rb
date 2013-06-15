module Skylab::Cull

  class API::Client < Face::API::Client

    CodeMolester::Config::Service.enhance self do

      default_init_directory do
        ::Dir.getwd
      end

      filename '.cullconfig'

      search_start_path do
        ::Dir.getwd
      end

      search_num_dirs 3

    end

    Headless::Plugin::Host.enhance self do
      services [ :config, :method, :config_controller ],
               [ :configs, :method, :config_collection ], *
               ( API::Client::Config_.fields.map do |fld|
                 [ :"config_#{ fld.normal }", :dispatch, :cfgdisp, fld.normal ]
               end )  # #experimental hack - not permanent like this
    end

    def config_collection
      model :configs
    end

    def config_controller
      model :config
    end

    Face::API::Client::Model[ self ]  # for `model` above

    def cfgdisp fld_i  # this allows us to flatten and unflatten the svc n.s
      config.send fld_i
    end
  end
end
