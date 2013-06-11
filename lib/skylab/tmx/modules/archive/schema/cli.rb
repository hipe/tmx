module Skylab::TMX::Modules::Schema

  class CLI < Skylab::Face::CLI

    set :desc, -> y do
      y << "part of the big dream, but off for now.."
    end

    # kexternal_dependencies "#{File.dirname(__FILE__)}/data/deps.json"

  end
end
