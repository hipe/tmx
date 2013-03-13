require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Semantic

  extend ::Skylab::Autoloader

  MetaHell = ::Skylab::MetaHell

  Semantic = self

  module Services
    h = {
      StringIO: -> do
        require 'stringio'
        ::StringIO
      end
     }
    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
