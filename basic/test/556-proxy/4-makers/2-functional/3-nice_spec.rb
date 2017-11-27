require_relative '../../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] proxy - makers - functional - 3. nice" do

    TS_[ self ]

    context "with a straight up-produced class" do

      dangerous_memoize_ :bingo_kls do
        Pxy_Fnctnl_03_01 = _subject :moo, :mar do
          attr_reader :two
          def initialize one, two
            @two = [ one, two ]
          end
        end
      end

      it "class / construct / inspect" do
        x = bingo_kls.new moo: 'x1', mar: 'x2'
        expect( x.class ).to eql Pxy_Fnctnl_03_01
        expect( x.inspect ).to eql(
          '#<Skylab::Basic::TestSupport::Pxy_Fnctnl_03_01 moo, mar>' )
        expect( x.two ).to eql( [ 'x1', 'x2' ] )
      end
    end

    context "with a subclass of a produced class" do

      dangerous_memoize_ :fingo_kls do
        Pxy_Fnctnl_03_02 = _subject :loo do
          attr_reader :liu
          def initialize liu
            @liu = liu
          end
        end
      end

      it "construct / class / inspect" do

        foo = fingo_kls.new loo: 'y'
        expect( foo.class ).to eql Pxy_Fnctnl_03_02
        expect( foo.inspect ).to eql(
          '#<Skylab::Basic::TestSupport::Pxy_Fnctnl_03_02 loo>' )
        expect( foo.liu ).to eql( 'y' )
      end
    end

    def _subject * sym_a, & blk
      Home_::Proxy::Makers::Functional::Nice.new( * sym_a, & blk )
    end
  end
end
