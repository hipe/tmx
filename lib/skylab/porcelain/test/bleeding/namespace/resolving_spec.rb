require_relative 'test-support'

module ::Skylab::Porcelain::TestSupport::Bleeding::Namespace # #po-008

  describe "[po][bl] namespace resolving" do

    extend Namespace_TestSupport

    context "among none" do
      namespace do
      end
      context "with none given" do
        token nil
        events { should be_event( :not_provided, 'expecting {}' ) }
      end
      context "with one given" do
        token 'herkemer'
        events { should be_event( :not_found, 'invalid action "herkemer". expecting {}' ) }
      end
    end
    context "among one" do
      namespace do
        class self::Ferp
          extend Bleeding::Action
        end
      end
      context "with none given" do
        token nil
        events { should be_event( :not_provided, "expecting {ferp}" ) }
      end
      context "with a correct one given" do
        token 'ferp'
        result { should eql( namespace::Ferp ) }
      end
      context "with a partial match given" do
        token 'fe'
        result { should eql( namespace::Ferp ) }
      end
      context "with an incorrect one given" do
        token 'fo'
        events { should be_event( :not_found, 'invalid action "fo". expecting {ferp}' ) }
      end
    end
    context "among two" do
      kls = Class.new.class_eval do
        self
      end
      namespace do
        class self::Derpa < kls ; end
        class self::Derka < kls ; end
      end
      context "with none given" do
        token nil
        events { should be_event( :not_provided, 'expecting {derpa|derka}' ) }
      end
      context "with a wrong one given" do
        token 'hoik'
        events { should be_event( /invalid action "hoik".*expecting/i ) }
      end
      context "with an ambiguous partial match given" do
        token 'der'
        events { should be_event( 'ambiguous action "der". did you mean derpa or derka?' ) }
      end
      context "with an umambiguous partial match given" do
        token 'derp'
        result { should eql( namespace::Derpa ) }
      end
      context "with a whole match given" do
        token 'derka'
        result { should eql( namespace::Derka ) }
      end
    end
  end
end
