require_relative '..'
require 'skylab/basic/core'
require 'skylab/code-molester/core'  # pub-sub too
require 'skylab/face/core'

module Skylab::Cull

  %i[ Basic CodeMolester Cull Face Headless PubSub MetaHell ].each do |i|
    const_set i, ::Skylab.const_get( i )
  end

  MAARS = MetaHell::Autoloader::Autovivifying::Recursive

  extend MAARS

  module CLI
    extend MAARS

    def self.new *a, &b
      self::Client.new( *a, &b )
    end
  end

  module API
    extend MAARS
    module Actions
      extend MetaHell::Boxxy
    end
    module Events_
      # gets filled with generated event classes
    end
  end

  module Models
    extend MetaHell::Boxxy
  end
end
