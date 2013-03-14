require File.expand_path('../api', __FILE__)

module Skylab::TMX
  module Modules::TeamCity
    class CLI < Skylab::Face::CLI
      namespace(:"team-city", :tc) do
        external_dependencies File.expand_path('../data/deps.json', __FILE__)
      end
    end
  end
end
