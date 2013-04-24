module Skylab::Basic

  module Hash

  end

  Hash::FUN = -> do

    o = { }

    o[:unpack] = -> h, *k_a do
      ( a = h.keys - k_a ).length.nonzero? and raise ::KeyError, "strict #{
        }unpack - unrecognized key(s) - (#{ a.map( & :inspect ) * ', ' })"
      k_a.map { |k| h.fetch k }
    end

    ::Struct.new( * o.keys ).new( * o.values )

  end.call
end
