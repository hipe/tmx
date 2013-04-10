require_relative '..'
require 'skylab/face/core'

module Skylab::Cull

  %i[ Face MetaHell ].each do |i|
    const_set i, ::Skylab.const_get( i )
  end

  MAARS = MetaHell::Autoloader::Autovivifying::Recursive

  module CLI
    extend MAARS

    def self.new *a, &b
      self::Client.new( *a, &b )
    end
  end
end
