require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Proxy
  once = -> do
    Bingo = MetaHell::Proxy::Nice::Basic.new :moo
    class Fingo < MetaHell::Proxy::Nice::Basic.new :loo
    end
    once = -> { }
    nil
  end

  describe "#{ MetaHell }::Proxy::Nice is nice" do
    it "it creates classes that creates objects that respond to .." do
      once[]
      boo = Bingo.new moo: 'x'
      foo = Fingo.new loo: 'y'
      ( boo.class == Bingo ).should eql( true )
      ( foo.class == Fingo ).should eql( true )
      boo.inspect.should eql(
        '#<Skylab::MetaHell::TestSupport::Proxy::Bingo moo>' )
      foo.inspect.should eql(
        '#<Skylab::MetaHell::TestSupport::Proxy::Fingo loo>' )
    end
  end
end
