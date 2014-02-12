module Skylab::TMX::Modules::Schema

  class CLI < Skylab::Face::CLI::Client

    set :desc, -> y do
      y << "part of the big dream, but off for now.."
    end

    def ping
      @y << "hello from schema."
      :hello_from_schema
    end

    # kexternal_dependencies "#{File.dirname(__FILE__)}/data/deps.json"

  end
end
