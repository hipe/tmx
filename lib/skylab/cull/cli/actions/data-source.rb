module Skylab::Cull

  class CLI::Actions::DataSource < CLI::Namespace

    option_parser do |o|
      # (ick for now this is necessary to get `aliases` working)
    end

    aliases :ls

    def list
      api
    end
  end
end
