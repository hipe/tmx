module Skylab::Callback

  module FUN  # read [#026] the FUN narrative

    Distill_proc = -> do  # [#026]:#the-distill-function
      Distill__
    end

    Distill__ = -> do
      black_rx = /[-_ ]+(?=[^-_])/  # preserve final trailing underscores & dashes ; [#bm-002]
      dash = '-'.getbyte 0
      empty_s = ''.freeze
      undr = '_'.getbyte 0
      -> x do
        s = x.to_s.gsub black_rx, empty_s
        d = 0 ; s.setbyte d, undr while dash == s.getbyte( d -= 1 )
        s.downcase.intern
      end
    end.call

  end
end
