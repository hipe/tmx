require_relative '../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN POS" do

    extend TS_

    context "noun" do

      it "default inflection is singular" do

        _subject.lemma.should eql 'foot'
      end

      it "plural sure-al" do

        _subject.plural.should eql 'foots'
      end

      it "`singular=` - redefines singular (e.g. if source is not sing.)" do

        _mutable_subject.singular = 'ferk'
        _mutable_subject.singular.should eql 'ferk'
      end

      it "`plural=` - e.g you can define irregular plurals for that noun" do

        _mutable_subject.plural = 'feet'
        _mutable_subject.plural.should eql 'feet'
      end

      same = -> do
        Hu_::NLP::EN::POS::Noun[ 'foot' ]
      end

      let :_mutable_subject do
        same[]
      end

      memoize_ :_subject do
        same[]
      end
    end

    context "verb" do

      context "`preterite`" do

        it "when not ends in 'e' - adds an 'ed'" do

          _subject_module::Verb[ 'add' ].preterite.should eql 'added'
        end

        it "when ends in 'e' - adds a 'd'" do

          _subject_module::Verb[ 'realize' ].preterite.should eql 'realized'
        end
      end

      context "`progressive`" do

        it "if ends in 'e', drops it" do

          _subject_module::Verb[ 'mate' ].progressive.should eql 'mating'
        end

        it "but normally, just adds 'ing'" do

          _subject_module::Verb[ 'do' ].progressive.should eql 'doing'
        end
      end

      def _subject_module
        Hu_::NLP::EN::POS
      end
    end
  end
end
