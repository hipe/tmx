require_relative '..'
require 'skylab/face/core'
require 'skylab/headless/core'
require 'skylab/porcelain/core'

module Skylab::SubTree

  ::Skylab::MetaHell::FUN::Import_constants[ ::Skylab, [
    :Autoloader,
    :Basic,
    :SubTree,
    :Headless,  # styles, parameter controller
    :MetaHell,
    :Porcelain,  # level-1 is this
    :PubSub
  ], self ]

  MetaHell::MAARS[ self ]

  module Core
    MetaHell::MAARS::Upwards[ self ]
  end

  DOT_ = '.'.freeze
  SEP_ = '/'.freeze

  Stop_at_pathname_ = -> do  # #todo
    rx = %r{\A[./]\z}  # hackishly - for all pn, parent eventually is this
    -> pn do
      rx =~ pn.instance_variable_get( :@path )
    end
  end.call

  ::Skylab::Subsystem[ self ]

end
