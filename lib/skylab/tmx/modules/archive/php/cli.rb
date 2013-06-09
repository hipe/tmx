module Skylab::TMX

  module Modules::Php

    class CLI < Skylab::Face::CLI

      set :desc, -> y do
        y << 'whatever.'
      end
      # external_dependencies File.expand_path('../data/deps.json', __FILE__)
    end
  end
end
