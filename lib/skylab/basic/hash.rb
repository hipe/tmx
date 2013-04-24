module Skylab::Basic

  module Hash

  end

  Hash::FUN = -> do
    o = MetaHell::Formal::Box::Open.new

    o[:unpack] = -> h, *k_a do
      ( a = h.keys - k_a ).length.nonzero? and raise ::KeyError, "strict #{
        }unpack - unrecognized key(s) - (#{ a.map( & :inspect ) * ', ' })"
      k_a.map { |k| h.fetch k }
    end

    o[:unpack_inner] = -> h, *k_a do
      ( a = h.keys - k_a ).length.nonzero? and raise ::KeyError, "unpack_#{
        }inner - unrecognized key(s) - (#{ a.map( & :inspect ) * ', ' })"
      k_a.map { |k| h.fetch k do end }
    end

    o[:unpack_softly] = -> h, *k_a do
      k_a.map { |k| h.fetch k do end }
    end

    o.to_struct                   # people just love using `at`
  end.call
end
