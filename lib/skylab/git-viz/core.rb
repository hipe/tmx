require_relative '..'
require 'skylab/porcelain/core'  # and [hl]

module Skylab::GitViz

  %i| GitViz Headless MetaHell Porcelain |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MetaHell::MAARS[ self ]

  module CLI
    SUCCEEDED_ = true
    MetaHell::MAARS::Upwards[ self ]

    module Actions__
      MetaHell::Boxxy[ self ]
    end
  end

  stowaway :API, 'api/session--'

  module VCS_Adapters_
    MetaHell::Boxxy[ self ]
  end

  module Services
    memoize = -> p do
      p_ = -> do
        r = p[] ; p_ = -> { r } ; r
      end
      -> { p_.call }
    end
    slugify = -> const_i do
      const_i.to_s.gsub( /(?<=[a-z])[A-Z]/ ) { |s| "-#{ s }" }.downcase
    end
    subsys = -> i do
      memoize[ -> do
        require "skylab/#{ slugify[ i ] }/core"
        ::Skylab.const_get i, false
      end ]
    end
    stdlib = -> i do
      memoize[ -> do
        require slugify[ i ]
        ::Object.const_get i, false
      end ]
    end

    Basic = subsys[ :Basic ]
    Grit = memoize[ -> do require 'grit' ; ::Grit end ]
    JSON = stdlib[ :JSON ]
    Open3 = stdlib[ :Open3 ]
    PubSub = subsys[ :PubSub ]
    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]
    StringScanner = memoize[ -> do require 'strscan' ; ::StringScanner end ]
  end
end
