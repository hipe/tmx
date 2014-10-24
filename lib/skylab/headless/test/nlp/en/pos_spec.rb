require_relative 'test-support'

module Skylab::Headless::TestSupport::NLP::EN

  describe "[hl] NLP EN POS" do

    context "NLP EN POS noun" do

      let :subject do
        Subject_[]::POS::Noun[ 'foot' ]
      end

      it "default inflection is singular" do
        subject.lemma.should eql( 'foot' )
      end

      it "plural sure-al" do
        subject.plural.should eql( 'foots' )
      end

      it "`singular=` - redefines singular (e.g. if source is not sing.)" do
        subject.singular = 'ferk'
        subject.singular.should eql( 'ferk' )
      end

      it "`plural=` - e.g you can define irregular plurals for that noun" do
        subject.plural = 'feet'
        subject.plural.should eql( 'feet' )
      end
    end

    context "NLP EN POS verb" do

      context "`preterite`" do

        it "when not ends in 'e' - adds an 'ed'" do
          v = subject::Verb[ 'add' ]
          v.preterite.should eql( 'added' )
        end

        it "when ends in 'e' - adds a 'd'" do
          v = subject::Verb[ 'realize' ]
          v.preterite.should eql( 'realized' )
        end
      end

      context "`progressive`" do
        it "if ends in 'e', drops it" do
          v = subject::Verb[ 'mate' ]
          v.progressive.should eql( 'mating' )
        end

        it "but normally, just adds 'ing'" do
          v = subject::Verb[ 'do' ]
          v.progressive.should eql( 'doing' )
        end
      end

      def subject
        Subject_[]::POS
      end
    end
  end
end
