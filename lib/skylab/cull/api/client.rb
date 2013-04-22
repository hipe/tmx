module Skylab::Cull

  class API::Client < Face::API::Client

    define_api_client do

      services_dslified %i|
        config_file_search_start_pathname
        config_file_search_num_dirs
        config_filename
        configs
        config
      |

    end

    config_file_search_start_pathname do
      ::Pathname.pwd
    end

    config_file_search_num_dirs do
      3
    end

    config_filename do
      Cull::Models::Config.filename
    end

    # `configs` - readability enhancement?

    configs do
      model :configs
    end

    config do
      model :config
    end
  end
end
