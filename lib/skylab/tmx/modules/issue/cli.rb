require_relative '../../../issue/porcelain'

module Skylab
  module Tmx
    module Issue
      extend ::Skylab::Porcelain
      namespace :'issue', ::Skylab::Issue::Porcelain, aliases: ['issues']
    end
  end
end
