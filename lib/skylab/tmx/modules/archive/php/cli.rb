require 'skylab/face/cli/external-dependencies'

module Skylab::TMX
  module Modules::Php
    class CLI < Skylab::Face::CLI
      namespace :"php" do
        external_dependencies File.expand_path('../data/deps.json', __FILE__)
      end
    end
  end
end
