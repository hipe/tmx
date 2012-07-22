require 'skylab/file-metrics/cli'

module Skylab
  module Tmx
    module FileMetrics
      extend ::Skylab::Porcelain
      namespace :'file-metrics', Skylab::FileMetrics::CLI, aliases: ['fm']
    end
  end
end
