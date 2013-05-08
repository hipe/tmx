require_relative '..'

require 'skylab/meta-hell/core'

module Skylab::Face

  %i| Face MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  extend MAARS

  module Services

    extend MAARS

    o = { }

    o[:Basic] = -> { Services::Headless::Services::Basic }

    o[:Headless] = -> { require 'skylab/headless/core' ; ::Skylab::Headless }

    o[:OptionParser] = -> { require 'optparse' ; ::OptionParser }

    o[:PubSub] = -> { require 'skylab/pub-sub/core' ; ::Skylab::PubSub }

    define_singleton_method :const_missing do |const|
      if o.key? const
        const_set const, o.fetch( const ).call
      else
        super const
      end
    end
  end
end
