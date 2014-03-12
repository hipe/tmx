require_relative '..'
require 'skylab/basic/core'
require 'skylab/face/core'
require 'skylab/meta-hell/core'
require 'skylab/headless/core'

module Skylab::BeautySalon

  %i( Basic BeautySalon Face Headless MetaHell ).each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  module CLI  # (avoiding orphan file by putting it here.)

    MAARS[ self ]

    def self.new *a
      const_get( :Client ).new( *a )
    end
  end

  # (:+[#su-001]:none)

  IDENTITY_ = -> x { x }          # for fun we track this

  MAARS[ self ]
end
