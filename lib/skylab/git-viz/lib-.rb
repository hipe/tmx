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
          require "skylab/#{ Callback_::Name.via_const( i ).as_slug }/core"
          ::Skylab.const_get i, false
        end ]
      end
    end.call

    # ~ universe modules, sidesystem facilities and short procs all as procs

    Brazen = sidesys[ :Brazen ]

    Basic = wall[ :Basic ]

    Basic_Set = -> * a do
      Basic[]::Set[ * a ]
    end

    CLI_legacy_DSL = -> mod do
      Porcelain__[]::Legacy::DSL[ mod ]
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    Date_time = memo[ -> do require 'date' ; ::DateTime end ]

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
      Callback_::Name.via_module( x ).as_lowercase_with_underscores_symbol
    end

    MH__ = wall[ :MetaHell ]

    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]

    NLP = -> do
      HL__[]::NLP
    end

    Open3 = stdlib[ :Open3 ]

    Option_parser = memo[ -> do require 'optparse' ; ::OptionParser end ]

    oxford = Callback_::Oxford

    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]

    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]

    Plugin = -> { HL__[]::Plugin }

    Porcelain__ = wall[ :Porcelain ]

    Power_scanner = -> * x_a do
      Callback_::Scn.multi_step.new_via_iambic x_a
    end

    Set = stdlib[ :Set ]

    Shellwords = stdlib[ :Shellwords ]

    Some_stderr_IO = -> do
      System[].IO.some_stderr_IO
    end

    Strange = -> x do
      MH__[].strange 120, x
    end

    String_scanner = memo[ -> do require 'strscan' ; ::StringScanner end ]

    System = -> do
      HL__[].system
    end

    Test_support = wall[ :TestSupport ]

    Tree = -> do
      Basic[]::Tree
    end

    # ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]
  end
end
