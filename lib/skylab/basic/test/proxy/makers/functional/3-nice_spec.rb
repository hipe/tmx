require_relative 'test-support'

module Skylab::Callback::TestSupport::Proxy

  describe "[ca] proxy - nice" do

    extend TS_

    context "with a straight up-produced class" do

      define_sandbox_constant :bingo_kls do
        Sandbox::Bingo = Subject_[].nice :moo, :mar do
          attr_reader :two
          def initialize one, two
            @two = [ one, two ]
          end
        end
      end

      it "class / construct / inspect" do
        x = bingo_kls.new moo: 'x1', mar: 'x2'
        x.class.should eql Sandbox::Bingo
        x.inspect.should eql(
          '#<Skylab::Callback::TestSupport::Proxy::Sandbox::Bingo moo, mar>' )
        x.two.should eql( [ 'x1', 'x2' ] )
      end
    end

    context "with a subclass of a produced class" do

      define_sandbox_constant :fingo_kls do
        Sandbox::Fingo = Subject_[].nice :loo do
          attr_reader :liu
          def initialize liu
            @liu = liu
          end
        end
      end

      it "construct / class / inspect" do
        foo = fingo_kls.new loo: 'y'
        foo.class.should eql Sandbox::Fingo
        foo.inspect.should eql(
          '#<Skylab::Callback::TestSupport::Proxy::Sandbox::Fingo loo>' )
        foo.liu.should eql( 'y' )
      end
    end
  end
end
