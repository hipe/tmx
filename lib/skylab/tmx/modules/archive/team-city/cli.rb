module Skylab::TMX

  module Modules::TeamCity

    class CLI < ::Skylab::Face::CLI::Client

      set :aliases, [ :tc ],
      :desc, -> y do
        y << "once were great warriors"
      end

      def ping
        @y << "hello from team city."
        :hello_from_team_city
      end

      # external_dependencies File.expand_path('../data/deps.json', __FILE__)

    end
  end
end
