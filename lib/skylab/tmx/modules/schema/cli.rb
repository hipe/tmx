require 'skylab/face/cli/external-dependencies'

module Skylab::TMX::Modules::Schema
  class CLI < Skylab::Face::CLI
    namespace :schema do
      external_dependencies "#{File.dirname(__FILE__)}/data/deps.json"
    end
  end
end
