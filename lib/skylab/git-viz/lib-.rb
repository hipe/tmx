module Skylab::GitViz

  module Lib_  # :+[#ss-001]

    stdlib, memo = Autoloader_.at :build_require_stdlib_proc, :memoize
    gem = stdlib

    wall = -> do

      skylab_top = memo[ -> do require_relative '..'  end ]

      -> i do
        memo[ -> do
          /\Arbx\b/i =~ ::RUBY_ENGINE and raise "cannot load '#{ i }' in rbx!"
          skylab_top[]
          require "skylab/#{ Name_.from_const( i ).as_slug }/core"
          ::Skylab.const_get i, false
        end ]
      end
    end.call

    # ~ modules as procs

    Basic = wall[ :Basic ]
    DateTime = memo[ -> do require 'date' ; ::DateTime end ]
    Grit = memo[ -> do require 'grit' ; ::Grit end ]
    JSON = stdlib[ :JSON ]
    Listen = gem[ :Listen ]
    MetaHell = wall[ :MetaHell ]
    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]
    Open3 = stdlib[ :Open3 ]
    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]
    Plugin = memo[ -> do Headless_::Plugin end ]
    Porcelain = wall[ :Porcelain ]
    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]
    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]
    TestSupport = wall[ :TestSupport ]
    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]

    # ~ procs as procs

    Ick = -> x do
      x.inspect  # placeholder for the future from the past
    end

    oxford = Callback_::Oxford
    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]
    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]

    Power_Scanner = -> * x_a do
      self::Basic[]::List::Scanner::Power.from_iambic x_a
    end
  end
end
