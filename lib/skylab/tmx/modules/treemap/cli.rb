require_relative '../../../treemap/core'

module Skylab
  module Tmx
    module Treemap
      extend ::Skylab::Porcelain
      namespace :'treemap', ::Skylab::Treemap::CLI
    end
  end
end
