module ::Skylab::TMX

  class CLI::Client

    namespace :'beauty-salon', -> do
      require 'skylab/beauty-salon/core'
      ::Skylab::BeautySalon::CLI::Client
    end, aliases: %i| bs |, skip: false

    namespace :cull, -> do
      require 'skylab/cull/core'
      ::Skylab::Cull::CLI::Client
    end, skip: false

    namespace :'cov-tree', -> do
      require 'skylab/cov-tree/core'
      ::Skylab::CovTree::CLI
    end, skip: false

    namespace :'file-metrics', -> do
      require 'skylab/file-metrics/core'
      ::Skylab::FileMetrics::CLI
    end,  aliases: [ 'fm' ], skip: false

    namespace :permute, -> do
      require 'skylab/permute/core'
      ::Skylab::Permute::CLI
    end, skip: false

    # (regret is left external for grease)

    namespace :slicer, -> do
      require 'skylab/slicer/core'
      ::Skylab::Slicer::CLI::Client
    end, skip: false

    namespace :snag, -> do
      require 'skylab/snag/core'
      ::Skylab::Snag::CLI
    end, aliases: [ :sg ], skip: false

    namespace :'tan-man', -> do
      require 'skylab/tan-man/core'
      ::Skylab::TanMan::CLI
    end, skip: false

    namespace :'treemap', -> do
      require 'skylab/treemap/core'
      ::Skylab::Treemap::CLI
    end, skip: false
  end

  module Modules::Strange
    # nothing.
  end
end
