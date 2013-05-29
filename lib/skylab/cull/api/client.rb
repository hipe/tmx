module Skylab::Cull

  class API::Client < Face::API::Client

    CodeMolester::Config::File::API_Client.enhance self do

      default_init_directory do
        ::Dir.getwd
      end

      filename '.cullconfig'

      search_start_pathname do
        ::Pathname.pwd
      end

      search_num_dirs 3

    end
  end
end
