require 'skylab/file-metrics/core'

class Skylab::TMX::CLI

  namespace :'file-metrics', -> { ::Skylab::FileMetrics::CLI }, aliases: [ 'fm' ]

end
