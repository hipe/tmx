require File.expand_path('../api', __FILE__)

module Skylab::Tmx
  module Modules::TeamCity
    class Cli < Skylab::Face::Cli
      namespace(:tc) do
        external_dependencies File.expand_path('../data/deps.json', __FILE__)
      end
    end
  end
end
