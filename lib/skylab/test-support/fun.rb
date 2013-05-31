module Skylab

  module TestSupport

    # this fun may be relied upon by coverage facilities which might need to
    # load as early as reasonably possible in the whole sequence hence this
    # is a "no fun" zone - we can't assume anything else has been loaded,
    # nor should we laod anything else.

  end

  TestSupport::FUN = -> do

    o = { }

    _spec_rb = '_spec.rb'.freeze

    o[:_spec_rb] = -> { _spec_rb }

    ::Struct.new( * o.keys ).new( * o.values )

  end.call
end
