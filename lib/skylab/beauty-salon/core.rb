require_relative '..'
require 'skylab/face/core'

module Skylab::BeautySalon

  %i| BeautySalon Face MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  Basic = Face::Services::Basic
  MAARS = MetaHell::MAARS

  extend MAARS

  module CLI  # (avoiding orphan file by putting it here.)

    extend MAARS

    def self.new *a
      const_get( :Client ).new( *a )
    end
  end

  module Services

    o = { }

    o[:Headless] = -> { Face::Services::Headless }

    define_singleton_method :const_missing do |i|

      const_set i, o.fetch( i ).call

    end
  end
end
