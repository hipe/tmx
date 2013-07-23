module Skylab::MetaHell

  module FUN::Parse

    Absorb_notify_ = -> a do
      op_h = self.op_h
      while a.length.nonzero?
        m = op_h.fetch( a.first ) { }
        m or break
        a.shift
        send m, a
      end
      nil
    end

    Op_h_via_private_instance_methods_ = -> kls do
      a = kls.private_instance_methods false
      hsh = ::Hash[ a.zip a ]
      hsh.default_proc = -> h, k do
        no = k.respond_to?( :id2name ) ? "\"#{ k }\"" : "(#{ k.class })"
        raise ::ArgumentError, "no: #{ no }. yes: (#{ h.keys * ', '})"
      end
      hsh
    end

    Fuzzy_Matcher_ = -> moniker, min do
      len = moniker.length
      -> tok do
        (( tlen = tok.length )) > len and break
        tlen < min && len >= min and break
        moniker[ 0, tlen ] == tok
      end
    end

    Parse = self
  end
end
