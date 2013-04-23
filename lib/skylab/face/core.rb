require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Face

  Face = self
  MetaHell = ::Skylab::MetaHell
  MAARS = MetaHell::Autoloader::Autovivifying::Recursive

  extend MAARS

  module Services

    extend MAARS

    o = { }

    o[:Basic] = -> { require 'skylab/basic/core' ; ::Skylab::Basic }

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
