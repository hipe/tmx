require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Face

  Face = self
  MetaHell = ::Skylab::MetaHell
  MAARS = MetaHell::Autoloader::Autovivifying::Recursive

  extend MAARS

  module Services

    o = { }

    o[:Headless] = -> { require 'skylab/headless/core' ; ::Skylab::Headless }

    o[:OptionParser] = -> { require 'optparse' ; ::OptionParser }

    define_singleton_method :const_missing do |const|
      const_set const, o.fetch( const ).call
    end
  end
end
