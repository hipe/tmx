class Skylab::TMX::CLI

  namespace :'file-metrics', -> do

    require 'skylab/file-metrics/core'

    ::Skylab::FileMetrics::CLI

  end,  aliases: [ 'fm' ]

end
