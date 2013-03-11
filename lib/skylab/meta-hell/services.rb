module Skylab::MetaHell

  module Services

    h = { }

    define_singleton_method( :o ) { |const, block| h[const] = block }

    o :Headless     , -> { require 'skylab/headless/core' ; ::Skylab::Headless }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
