module Skylab::TMX

  module Modules::Xpdf

    class CLI < Skylab::Face::CLI

      set :desc, -> y do
        y << "idem."
      end

      # external_dependencies File.expand_path('../data/deps.json', __FILE__)

    end
  end
end
