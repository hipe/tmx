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
          require "skylab/#{ Name_.from_const( i ).as_slug }/core"
          ::Skylab.const_get i, false
        end ]
      end
    end.call

    # ~ universe modules, sidesystem facilities and short procs all as procs

    Basic__ = wall[ :Basic ]

    Basic_Set = -> * a do
      self::Basic__[]::Set[ * a ]
    end

    DateTime = memo[ -> do require 'date' ; ::DateTime end ]

    Formal_attribute_definer = -> mod do
      self::MetaHell__[]::Formal::Attribute::Definer[ mod ] ; nil
    end

    Grit = memo[ -> do require 'grit' ; ::Grit end ]

    Headless = Headless__ = sidesys[ :Headless ]

    Ick = -> x do  # this one is not behind a wall, but #todo:when-ba-purifies
      x.inspect  # placeholder for the future from the past
    end

    Inspect = -> x do
      self::Basic__[]::FUN::Inspect__[ 120, x ]
    end

    JSON = stdlib[ :JSON ]
    Listen = gem[ :Listen ]

    Local_normal_name_from_module = -> x do
      self::Headless__[]::Name::FUN::Local_normal_name_from_module[ x ]
    end

    Memoize = Callback_.memoize
    MetaHell__ = wall[ :MetaHell ]
    MD5 = memo[ -> do require 'digest/md5' ; ::Digest::MD5 end ]
    Open3 = stdlib[ :Open3 ]
    OptionParser = memo[ -> do require 'optparse' ; ::OptionParser end ]

    oxford = Callback_::Oxford
    Oxford_or = oxford.curry[ ', ', '[none]', ' or ' ]
    Oxford_and = oxford.curry[ ', ', '[none]', ' and ' ]

    Plugin = -> { self::Headless__[]::Plugin }
    Porcelain = wall[ :Porcelain ]

    Power_Scanner = -> * x_a do
      self::Basic__[]::List::Scanner::Power.from_iambic x_a
    end

    Set = stdlib[ :Set ]
    Shellwords = stdlib[ :Shellwords ]

    Simple_monadic_iambic_writers = -> * a do
      self::Headless__[]::API::Simple_monadic_iambic_writers[ * a ]
    end

    Some_stderr_IO = -> do
      self::Headless__[]::System::IO.some_stderr_IO
    end

    StringScanner = memo[ -> do require 'strscan' ; ::StringScanner end ]
    TestSupport = wall[ :TestSupport ]

    Unstyle_styled = -> x do
      self::Headless__[]::CLI::Pen::FUN::Unstyle_styled[ x ]
    end

    ZMQ = memo[ -> do require 'ffi-rzmq' ; ::ZMQ end ]
  end
end
