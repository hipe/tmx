require File.expand_path('../../../face/cli/external-dependencies', __FILE__)
require 'ruby-debug'

module Skylab::Tmx::Modules::Schema
  class Cli < Skylab::Face::Cli
    namespace :schema do
      external_dependencies "#{File.dirname(__FILE__)}/data/external-dependencies.json"
    end
  end
end
