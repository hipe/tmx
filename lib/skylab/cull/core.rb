require_relative '..'

require 'skylab/basic/core'
require 'skylab/code-molester/core'  # [cb] too
require 'skylab/face/core'

module Skylab::Cull

  %i[ Basic CodeMolester Cull Face Headless Callback MetaHell ].each do |i|
    const_set i, ::Skylab.const_get( i )
  end

  MAARS = MetaHell::MAARS

  MAARS[ self ]

  module CLI
    MAARS[ self ]

    def self.new *a, &b
      self::Client.new( *a, &b )
    end
  end

  module API
    MAARS[ self ]
    module Actions
      MetaHell::Boxxy[ self ]
    end
    module Events_
      # gets filled with generated event classes
    end
  end

  module Models
    MetaHell::Boxxy[ self ]
  end

  module Lib_  # :+[#su-001]
    FileUtils = -> do require 'fileutils' ; ::FileUtils end
  end
end
