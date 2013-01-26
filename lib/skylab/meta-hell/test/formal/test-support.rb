require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Formal
  ::Skylab::MetaHell::TestSupport[ Formal_TestSupport = self ]

  include CONSTANTS

  MetaHell = MetaHell # bc of metahell

  extend TestSupport::Quickie

  FUN = -> do
    o = { }
    counter = 0
    o[:next_id] = -> { counter += 1 }
    st = Struct.new(* o.keys ).new ; o.each { |k, v| st[k] = v } ; st.freeze
    st
  end.call
end
