module Skylab::MetaHell

  o = { }

  o[:hash2instance] = -> h do
    i = MetaHell::Plastic::Instance.new
    h.each { |k, f| i.define_singleton_method k, &f }
    i
  end

  o[:hash2struct] = -> h do
    s = ::Struct.new(* h.keys ).new ; h.each { |k, v| s[k] = v } ; s
  end

  FUN = o[:hash2struct][ o ]

end
