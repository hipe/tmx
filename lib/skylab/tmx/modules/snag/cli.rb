require_relative '../../../snag/core'

module Skylab
  module Tmx
    module Snag
      extend ::Skylab::Porcelain::Legacy::DSL
      namespace :snag, ::Skylab::Snag::CLI
    end
  end
end
