module ::Skylab::TMX

  class CLI

    namespace :'beauty-salon', -> do
      require 'skylab/beauty-salon/core'
      ::Skylab::BeautySalon::CLI::Client
    end, aliases: %i| bs |, skip: true

    namespace :cull, -> do
      require 'skylab/cull/core'
      ::Skylab::Cull::CLI::Client
    end, skip: false

    namespace :'cov-tree', -> do
      require 'skylab/cov-tree/core'
      ::Skylab::CovTree::CLI
    end, skip: true

    namespace :'file-metrics', -> do
      require 'skylab/file-metrics/core'
      ::Skylab::FileMetrics::CLI
    end,  aliases: [ 'fm' ], skip: false

    namespace :permute, -> do
      require 'skylab/permute/core'
      ::Skylab::Permute::CLI
    end, skip: true

    # (regret is left external for grease)

    namespace :slicer, -> do
      require 'skylab/slicer/core'
      ::Skylab::Slicer::CLI::Client
    end, skip: true

    namespace :snag, -> do
      require 'skylab/snag/core'
      ::Skylab::Snag::CLI
    end, aliases: [ :sg ], skip: true

    namespace :'tan-man', -> do
      require 'skylab/tan-man/core'
      ::Skylab::TanMan::CLI
    end, skip: true

    namespace :'treemap', -> do
      require 'skylab/treemap/core'
      ::Skylab::Treemap::CLI
    end, skip: false
  end

  module Modules::Strange
    # nothing.
  end
end
