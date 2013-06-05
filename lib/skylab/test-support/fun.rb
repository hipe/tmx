module Skylab

  module TestSupport

    # this fun may be relied upon by coverage facilities which might need to
    # load as early as reasonably possible in the whole sequence hence this
    # is a "no fun" zone - we can't assume anything else has been loaded,
    # nor should we load anything else.

  end

  TestSupport::FUN = -> do

    o = { }  # these are just here for now as logical placeholders..
    # it could be made more extensible. as they are now they are just one
    # step up from duplicating the literals througout the universe.

    o[:_spec_rb] = -> do
      _spec_rb = '_spec.rb'.freeze
      -> { _spec_rb }
    end.call

    o[:test_support_filenames] = -> do
      a = [ 'test-support.rb' ].freeze
      -> { a }
    end.call

    ::Struct.new( * o.keys ).new( * o.values )

  end.call
end
