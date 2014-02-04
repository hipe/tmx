module Skylab::GitViz

  module Lib_

    memo = -> p do
      p_ = -> { x = p[] ; p_ = -> { x } ; x }
      -> { p_.call }
    end

    sl = -> do
      require_relative '..' ; sl = nil
    end

    subsys = -> i do
      memo[ -> do
        /\Arbx\b/i =~ ::RUBY_ENGINE and raise "cannot load '#{ i }' in rbx!"
        sl && sl[]
        require "skylab/#{ Name_.from_const( i ).as_slug }/core"
        ::Skylab.const_get i, false
      end ]
    end

    purified_, stdlib_ = Autoloader_.at :require_subsystem, :require_stdlib

    purified = -> i do
      -> { purified_[ i ] }
    end

    stdlib = -> i do
      -> { stdlib_[ i ] }
    end

    gem = stdlib

    Basic = subsys[ :Basic ]
    DateTime = memo[ -> do require 'date' ; ::DateTime end ]
    Grit = memo[ -> do require 'grit' ; ::Grit end ]
    Headless = purified[ :Headless ]
    JSON = stdlib[ :JSON ]
    Listen = gem[ :Listen ]
    MetaHell = subsys[ :MetaHell ]
    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]
    Open3 = stdlib[ :Open3 ]
    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]
    Plugin = memo[ -> do Headless[]::Plugin end ]
    Porcelain = subsys[ :Porcelain ]
    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]
    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]
    TestSupport = subsys[ :TestSupport ]
    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]

    Ick = -> x do
      x.inspect  # placeholder for the future from the past
    end

    oxford = Callback_::Oxford
    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]
    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]
  end
end
