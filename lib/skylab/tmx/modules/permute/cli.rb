require 'skylab/permute/cli'

module Skylab::Tmx::Modules::Permute
  class Cli < Skylab::Face::Cli
    namespace :permute, ::Skylab::Permute::Cli
  end
end

