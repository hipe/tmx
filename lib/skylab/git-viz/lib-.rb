module Skylab::GitViz

  module Lib_  # :+[#ss-001]

    memo, sidesys, stdlib = Autoloader_.at :memoize,
      :build_require_sidesystem_proc, :build_require_stdlib_proc

    gem = stdlib

    wall = -> do

      skylab_top = memo[ -> do require_relative '..'  end ]

      -> i do
        memo[ -> do
          /\Arbx\b/i =~ ::RUBY_ENGINE and raise "cannot load '#{ i }' in rbx!"
          skylab_top[]
          require "skylab/#{ Name_.via_const( i ).as_slug }/core"
          ::Skylab.const_get i, false
        end ]
      end
    end.call

    # ~ universe modules, sidesystem facilities and short procs all as procs

    Bsc__ = wall[ :Basic ]

    Basic_Set = -> * a do
      Bsc__[]::Set[ * a ]
    end

    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    DateTime = memo[ -> do require 'date' ; ::DateTime end ]

    Formal_attribute_definer = -> mod do
      MH__[]::Formal::Attribute::Definer[ mod ] ; nil
    end

    Grit = memo[ -> do require 'grit' ; ::Grit end ]

    HL__ = sidesys[ :Headless ]

    Ick = -> x do  # this one is not behind a wall, but #todo:when-ba-purifies
      x.inspect  # placeholder for the future from the past
    end

    JSON = stdlib[ :JSON ]

    Listen = gem[ :Listen ]

    Local_normal_name_from_module = -> x do
      Old_name_lib[].local_normal_name_from_module x
    end

    Memoize = Callback_.memoize

    MH__ = wall[ :MetaHell ]

    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]

    Old_name_lib = -> do
      HL__[]::Name
    end

    Open3 = stdlib[ :Open3 ]

    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]

    oxford = Callback_::Oxford

    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]

    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]

    Plugin = -> { HL__[]::Plugin }

    Porcelain__ = wall[ :Porcelain ]

    Power_Scanner = -> * x_a do
      Callback_::Scn.multi_step.build_via_iambic x_a
    end

    Set = stdlib[ :Set ]

    Shellwords = stdlib[ :Shellwords ]

    Some_stderr_IO = -> do
      System[].IO.some_stderr_IO
    end

    Strange = -> x do
      MH__[].strange 120, x
    end

    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]

    SubTree__ = sidesys[ :SubTree ]

    System = -> do
      HL__[].system
    end

    Test_support = wall[ :TestSupport ]

    Tree = -> do
      SubTree__[]::Tree
    end

    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]
  end
end
