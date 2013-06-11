require_relative '..'
require 'skylab/face/core'
require 'skylab/headless/core'

module Skylab::FileMetrics

  [ :Face, :FileMetrics, :MetaHell, :Headless ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  MAARS = MetaHell::MAARS

  # as one alternative to another..
  [ :API, :Common, :Model, :Models ].each do |c|
    ( const_set c, ::Module.new ).extend MAARS
  end

  extend MAARS  # because CLI is a class

  const_get :Services, false  # because it is a leaf, meh just load it now

  module API  # #stowaway
    module Actions
      extend MetaHell::Boxxy
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
