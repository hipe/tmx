require_relative '../../../treemap/cli'

module Skylab
  module Tmx
    module Treemap
      extend ::Skylab::Porcelain
      namespace :'treemap', ::Skylab::Treemap::CLI
    end
  end
end


