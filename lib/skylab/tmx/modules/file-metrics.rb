require 'skylab/file-metrics/core'

module Skylab
  module Tmx
    module FileMetrics
      extend ::Skylab::Porcelain::Legacy::DSL
      namespace :'file-metrics', Skylab::FileMetrics::CLI, aliases: ['fm']
    end
  end
end
