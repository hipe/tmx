require File.expand_path('../../../../cov-tree/porcelain', __FILE__)

module Skylab
  module Tmx
    module CovTree
      extend ::Skylab::Porcelain
      namespace :'cov-tree', ::Skylab::CovTree::Porcelain
    end
  end
end

