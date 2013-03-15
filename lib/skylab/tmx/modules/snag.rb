class Skylab::TMX::CLI

  namespace :snag, -> do

    require 'skylab/snag/core'

    ::Skylab::Snag::CLI

  end, aliases: [ :sg ]

end
