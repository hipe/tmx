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

    context "does it work if you don't subclass it?" do

      define_method :klass, & MetaHell::FUN.memoize[ -> do
        const = "KLS_#{ Proxy_TestSupport.next_id }"
        kls = MetaHell::Proxy::Nice::Basic.new :weazel, :skeezel
        Proxy_TestSupport.const_set const, kls
        kls
      end ]

      it "does not work like a functional proxy" do
        klass.name.should be_include( 'TestSupport::Proxy::KLS' )
        wzl = szl = nil
        proxy_object = klass.new(
          weazel: -> { wzl = :yep },
          skeezel: -> x { szl = "moink : #{ x }" }
        )
        begin
          proxy_object.weazel
        rescue ::NoMethodError => e
        end
        e.message.should match( /\Aundefined method `weazel' for/ )
      end
    end
  end
end
