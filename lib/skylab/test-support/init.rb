module Skylab

  module TestSupport

    module Init  # this node may be loaded before even the core file for
      # this subsystem is loaded so that these constants can be used to
      # generate test coverage, where that coverage may even be for
      # arbitrary nodes in this subystem (other than this one). so don't
      # pull in any other files from this one, and don't expect to have
      # any accesss to any subsystem facilities here.

      define_singleton_method :spec_rb, -> do
        p = -> do
          x = '_spec.rb'.freeze  # or look up in a config file
          p = -> { x }
          x
        end
        -> { p[] }
      end.call

      define_singleton_method :test_support_filenames, -> do
        p = -> do
          x = [ 'test-support.rb'.freeze ].freeze
          p = -> { x }
          x
        end
        -> { p[] }
      end.call

    end
  end
end
