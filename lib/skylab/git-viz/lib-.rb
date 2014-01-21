module Skylab::GitViz

  module Lib_

    memo = -> p do
      p_ = -> { x = p[] ; p_ = -> { x } ; x }
      -> { p_.call }
    end

    slug = -> i do
      i.to_s.gsub( %r((?<=[a-z])(?=[A-Z])), '-' ).downcase
    end

    sl = -> do
      require_relative '..' ; sl = nil
    end

    subsys = -> i do
      memo[ -> do
        sl && sl[]
        require "skylab/#{ slug[ i ] }/core" ; ::Skylab.const_get i, false
      end ]
    end

    stdlib = -> i do
      memo[ -> do
        require slug[ i ] ; ::Object.const_get i, false
      end ]
    end

    Basic = subsys[ :Basic ]
    DateTime = memo[ -> do require 'date' ; ::DateTime end ]
    Grit = memo[ -> do require 'grit' ; ::Grit end ]
    Headless = subsys[ :Headless ]
    JSON = stdlib[ :JSON ]
    MetaHell = subsys[ :MetaHell ]
    Open3 = stdlib[ :Open3 ]
    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]
    Porcelain = subsys[ :Porcelain ]
    PubSub = subsys[ :PubSub ]
    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]
    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]
    TestSupport = subsys[ :TestSupport ]
    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]

  end
end
