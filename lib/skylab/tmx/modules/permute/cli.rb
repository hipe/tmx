require 'skylab/permute/cli'

module Skylab
  module Tmx
    module Permute
      extend ::Skylab::Porcelain
      namespace :permute, ::Skylab::Permute::CLI
    end
  end
end

