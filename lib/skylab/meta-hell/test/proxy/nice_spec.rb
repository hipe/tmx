require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Proxy

  module SANDBOX
  end

  describe "#{ MetaHell }::Proxy::Nice is nice" do

    context "with a straight up-produced class" do
      once = -> do
        kls = SANDBOX::Bingo = MetaHell::Proxy::Nice::Basic.new :moo, :mar
        kls.class_exec do
          attr_reader :two
          def initialize one, two
            @two = [ one, two ]
          end
        end
        ( once = -> { kls } ).call
      end

      it "class / construct / inspect" do
        x = once[].new moo: 'x1', mar: 'x2'
        ( SANDBOX::Bingo == x.class ).should eql( true )
        x.inspect.should eql(
          '#<Skylab::MetaHell::TestSupport::Proxy::SANDBOX::Bingo moo, mar>' )
        x.two.should eql( [ 'x1', 'x2' ] )
      end
    end

    context "with a subclass of a produced class" do
      once = -> do
        class SANDBOX::Fingo < MetaHell::Proxy::Nice::Basic.new :loo
          attr_reader :liu
          def initialize liu
            @liu = liu
          end
        end
        k = SANDBOX::Fingo
        ( once = -> { k } ).call
      end

      it "construct / class / inspect" do
        foo = once[].new loo: 'y'
        ( SANDBOX::Fingo == foo.class ).should eql( true )
        foo.inspect.should eql(
          '#<Skylab::MetaHell::TestSupport::Proxy::SANDBOX::Fingo loo>' )
        foo.liu.should eql( 'y' )
      end
    end

    context "does it work if you don't subclass it?" do

      define_method :klass, & MetaHell::FUN.memoize[ -> do
        const = "KLS_#{ Proxy_TestSupport.next_id }"
        kls = MetaHell::Proxy::Nice::Basic.new :weazel, :skeezel
        kls.class_eval do
          def initialize w, s
            @alpha, @beta = w, s
          end
          def go
            @alpha.call
            @beta.call 'ohai'
            :gamma
          end
        end
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

        proxy_object.go.should eql( :gamma )
        wzl.should eql( :yep )
        szl.should eql( "moink : ohai" )
      end
    end
  end
end
