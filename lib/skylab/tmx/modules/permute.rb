require 'skylab/permute/core'

module Skylab
  module Tmx
    module Permute
      extend ::Skylab::Porcelain::Legacy::DSL
      namespace :permute, ::Skylab::Permute::CLI
    end
  end
end
