require 'skylab/permute/core'

module Skylab
  module Tmx
    module Permute
      extend ::Skylab::Porcelain
      namespace :permute, ::Skylab::Permute::CLI
    end
  end
end
