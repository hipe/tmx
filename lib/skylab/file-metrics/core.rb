require_relative '..'
require 'skylab/face/core'
require 'skylab/headless/core'

module Skylab::FileMetrics

  [ :Face, :FileMetrics, :MetaHell, :Headless ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  ::Skylab::Subsystem[ self ]

  # as one alternative to another..
  [ :API, :Common, :Model, :Models ].each do |c|
    MAARS[ const_set c, ::Module.new ]
  end

  module API  # #stowaway
    module Actions
      MetaHell::Boxxy[ self ]
    end
  end

  FUN = -> do  # #stowaway
    rx = /[ $']/
    ::Struct.new( :shellescape_path )[
      -> x do
        rx =~ x ? Services::Shellwords.shellescape( x ) : x
      end
    ]
  end.call
end
