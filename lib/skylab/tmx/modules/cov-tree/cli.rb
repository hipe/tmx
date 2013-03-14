require_relative '../../../cov-tree/core'

module Skylab
  module Tmx
    module CovTree
      extend ::Skylab::Porcelain::Legacy::DSL  # #todo this is transitional
      namespace :'cov-tree', ::Skylab::CovTree::CLI
    end
  end
end
