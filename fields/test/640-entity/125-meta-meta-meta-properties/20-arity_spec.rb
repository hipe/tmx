require_relative '../../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - meta-meta-meta-properties - arity" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    it "(subject library loads)" do
      subject_library_ || fail
    end

    it "(subject module loads)" do
      _subject_module || fail
    end

    context "an arity space when sent .." do

      it "members - duped array of members" do

        a = _subject.members
        a.should eql [ :zero_or_one, :one_or_more ]
        _subject.members.object_id == a.object_id && fail
      end

      it "aref ([]) - with ok name" do
        _subject[ :zero_or_one ].should eql _subject::ZERO_OR_ONE
      end

      it "aref ([]) - with bad name - nil" do
        _subject[ :not_there ].should be_nil
      end

      it "fetch - with good name" do
        _subject.fetch( :one_or_more ).should eql _subject::ONE_OR_MORE
      end

      it "fetch - bad name and default" do
        _subject.fetch( :no ) { :x }.should eql :x
      end

      it "fetch - with bad name and no default" do
        -> do
          _subject.fetch :nope
        end.should raise_error ::KeyError, /key not found: :nope/
      end

      context "the zero or one arity when sent" do

        it "name_symbol - ok" do
          arity.name_symbol.should eql :zero_or_one
        end

        it "includes_zero - yes" do
          arity.includes_zero || fail
        end

        it "is_polyadic - no" do
          arity.is_polyadic && fail
        end

        it "include?( 0 ) - yes" do
          arity.should be_include 0
        end

        it "include?( 1 ) - yes" do
          arity.should be_include 1
        end

        it "include?( 2 ) - no" do
          arity.include? 2 and fail
        end

        def arity
          _subject.fetch :zero_or_one
        end
      end

      context "the one or more arity when sent" do

        it "name_symbol - ok" do
          arity.name_symbol.should eql :one_or_more
        end

        it "includes_zero - no" do
          arity.includes_zero && fail
        end

        it "is_polyadic - yes" do
          arity.is_polyadic || fail
        end

        it "include?( 0 ) - false" do
          arity.include? 0 and fail
        end

        it "include?( 1 ) - yes" do
          arity.should be_include 1
        end

        it "include?( 2 ) - yes" do
          arity.should be_include 2
        end

        def arity
          _subject.fetch :one_or_more
        end
      end

      shared_subject :_subject do

        cls = _subject_module::Space.create do
          self::ZERO_OR_ONE = new 0, 1
          self::ONE_OR_MORE = new 1, nil
        end
        X_en_mmmp_One = cls
        cls
      end
    end

    # ==

    def _subject_module
      subject_library_::MetaMetaMetaProperties::Arity
    end

    # ==
  end
end
