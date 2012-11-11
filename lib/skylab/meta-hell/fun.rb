module Skylab::MetaHell

  o = { }

  o[:hash2struct] = -> h do
    s = ::Struct.new(* h.keys ).new ; h.each { |k, v| s[k] = v } ; s
  end

  FUN = o[:hash2struct][ o ]

end
