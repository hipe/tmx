module Skylab

  module TestSupport

    # this fun may be relied upon by coverage facilities which might need to
    # load as early as reasonably possible in the whole sequence hence this
    # is a "no fun" zone - we can't assume anything else has been loaded,
    # nor should we load anything else.

    FUN = class Fun__ < ::Module  # #transitional
      self
    end.new

    module FUN

      # these are just here for now as logical placeholders..
      # it could be made more extensible. as they are now they are just one
      # step up from duplicating the literals througout the universe.

      Spec_rb = -> do
        s = '_spec.rb'.freeze
        -> { s }
      end.call
      class TestSupport::Fun__  # #transitional
        def _spec_rb ; Spec_rb end
      end

      Test_support_filenames = -> do  # #transitional
        a = %w( test-support.rb' ).freeze
        -> { a }
      end.call
      class TestSupport::Fun__
        def test_support_filenames ; Test_support_filenames end
      end
    end
  end
end
