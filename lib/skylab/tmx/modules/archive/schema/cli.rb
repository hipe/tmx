module Skylab::TMX

  module Modules::Schema  # ..

  class CLI < CLI_Client_[]

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
end
