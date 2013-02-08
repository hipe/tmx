require_relative '../test-support'

module Skylab::Headless::TestSupport::CLI
  ::Skylab::Headless::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  module ModuleMethods

    # we are flagrantly breaking the fundamental rules of unit testing for fun:

    include CONSTANTS  # necessary - to speak of m.h below

    memoize = MetaHell::FUN.memoize

    define_method :klass do |name, &block|

      klass = memoize[ -> do
        kls = CLI_TestSupport.const_set name, ::Class.new
        kls.class_exec(& block )
        kls
      end ]

      streams = memoize[ -> do
        Headless_TestSupport::CLI::Streams_Spy.new
      end ]

      instance = memoize[ -> do
        klass[].new(* streams[].values )
      end ]

      define_method :debug! do
        streams[].debug!
      end

      serr = nil

      define_method :invoke do |argv|
        streams[].clear_buffers
        serr = memoize[ -> do
          streams[].errstream.string.split "\n"
        end ]
        instance[].invoke argv
      end

      define_method :serr do
        serr[]
      end
    end
  end

  module InstanceMethods
    include CONSTANTS

    define_method :styled, & Headless::CLI::Pen::FUN.unstylize_stylized
  end
end
