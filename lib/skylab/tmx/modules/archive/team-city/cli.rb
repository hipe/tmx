module Skylab::TMX

  module Modules::TeamCity

    class CLI < ::Skylab::Face::CLI

      set :aliases, [ :tc ],
      :desc, -> y do
        y << "once were great warriors"
      end

      # external_dependencies File.expand_path('../data/deps.json', __FILE__)

    end
  end
end
