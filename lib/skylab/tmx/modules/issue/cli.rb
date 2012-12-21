require_relative '../../../issue/core'

module Skylab
  module Tmx
    module Issue
      extend ::Skylab::Porcelain
      namespace :'issue', ::Skylab::Issue::CLI, aliases: ['issues']
    end
  end
end
