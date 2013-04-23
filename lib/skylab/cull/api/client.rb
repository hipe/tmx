module Skylab::Cull

  class API::Client < Face::API::Client

    CodeMolester::Config::File::API_Client.enhance self do

      search_start_pathname do
        ::Pathname.pwd
      end

      search_num_dirs 3

      config_filename '.cullconfig'

    end
  end
end
