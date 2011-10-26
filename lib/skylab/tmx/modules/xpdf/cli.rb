require 'skylab/face/cli/external-dependencies'

module Skylab::Tmx
  module Modules::Xpdf
    class Cli < Skylab::Face::Cli
      namespace :"xpdf" do
        external_dependencies File.expand_path('../data/deps.json', __FILE__)
      end
    end
  end
end

