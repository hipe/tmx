require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node identifier" do

    extend TS_

    it "loads" do
      _subject
    end

    it "on two ID's without suffixes, comparison than works" do

      one = _one ; two = _two

      two.between?( one, two ).should eql true
      two.between?( one, one ).should eql false
      one.between?( one, one ).should eql true
      one.between?( two, two ).should eql false
    end

    _Subject = -> do
      Home_::Models_::Node_Identifier
    end

    context "suffixes - use '.', '-', or '/' to separate components" do

      it "node identifiers (with suffix) are the frontier of ACS" do

        _subject or fail
      end

      it "nodes with suffixes retain the separators used" do

        _subject.suffix_separator_at_index( 0 ).should eql '.'
      end

      it "components that do not look like integers are strings" do

        _subject.suffix_value_at_index( 0 ).should eql 'xyz'
      end

      it "components that look like [negative] integers are integers" do

        o = _subject
        o.suffix_separator_at_index( 1 ).should eql '-'
        o.suffix_value_at_index( 1 ).should eql( -23 )
      end

      it "etc" do

        o = _subject
        o.suffix_separator_at_index( 2 ).should eql '/'
        o.suffix_value_at_index( 2 ).should eql 'A'
      end

      it "requesting a separator off the end gives you nil" do

        _subject.suffix_separator_at_index( 3 ).should be_nil
      end

      it "requiesting a component off the end gives you nil" do

        _subject.suffix_value_at_index( 3 ).should be_nil
      end

      it "suffix components cannot be the empty string, so" do

        o = _new_via_integer_and_suffix_string 1, '...'
        o.suffix_separator_at_index( 0 ).should eql '.'
        o.suffix_value_at_index( 0 ).should eql '..'
        o.suffix_separator_at_index( 1 ).should be_nil
        o.suffix_value_at_index( 1 ).should be_nil
      end

      it "ditto" do

        o = _new_via_integer_and_suffix_string 1, 'A'
        o.suffix_separator_at_index( 0 ).should be_nil
        o.suffix_value_at_index( 0 ).should eql 'A'
      end

      it "comparison of integer component works" do

        ( _( 3, 'A.-2.b' ) < _( 3, 'A.-1.a' ) ).should eql true
      end

      it "comparison of string component uses platform <=>" do

        ( _( 3, '-23d.10' ) < _( 3, '-24d.09' ) ).should eql true
      end

      it "nodes who are same with same suffixes are same" do

        ( _( 3, '.A-10/-10' ) <=> _( 3, '.A-10/-10' ) ).should be_zero
      end

      it "the string used for the separator is used in the comparison!" do

        _a = _ 3, '.A-B/C'
        _b = _ 3, '.A-B-C'
        ( _a <=> _b ).should eql 1
      end

      def _ d, s
        _new_via_integer_and_suffix_string d, s
      end

      _New_via_integer_and_suffix_string = -> d, ss do

        _Subject[].edit_entity(
          :via, :string, :set, :suffix, ss,
          :set, :integer, d
        )
      end

      define_method :_new_via_integer_and_suffix_string,
        _New_via_integer_and_suffix_string

      memoize :_subject do
        _New_via_integer_and_suffix_string[ 3, '.xyz--23/A' ]
      end
    end

    memoize :_one do
      _new_via_integer 1
    end

    memoize :_two do
      _new_via_integer 2
    end

    define_singleton_method :_new_via_integer do | d |
      _Subject[].send :new, d
    end

    define_method :_subject do
      _Subject[]
    end

    alias_method :_parent_subject, :_subject
  end
end
