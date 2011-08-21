require 'skylab/face/cli/external-dependencies'

module Skylab::Tmx::Modules::Schema
  class Cli < Skylab::Face::Cli
    namespace :schema do
      external_dependencies "#{File.dirname(__FILE__)}/data/external-dependencies.json"
    end
  end
end
