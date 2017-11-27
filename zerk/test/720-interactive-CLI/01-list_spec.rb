require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - list interpretation (like OGDL)" do

    TS_[ self ]
    use :want_event

    it "loads" do
      _subject
    end

    it "empty" do
      _ EMPTY_S_, EMPTY_A_
    end

    it "(non-empty) blank string" do
      _ SPACE_, EMPTY_A_
    end

    it "one-char token" do
      _ 'a', %w( a )
    end

    it "two-char token" do

      _ 'aa', %w( aa )
    end

    it "word word" do

      _ 'w1 w2', %w( w1 w2 )
    end

    it "single quote left open" do

      _against "'"
      _error :unclosed_quote do | y |
        y.should eql [ 'expecting "\'".' ]
      end
    end

    it "simple word in quotes" do

      _ '"w1"', %w( w1 )
    end

    it "word in quotes then space" do

      _ '"w1" ', %w( w1 )
    end

    it "word word in quotes" do
      _ '"w1 w2"', [ 'w1 w2' ]
    end

    it "space word comma word space space all in quotes" do

      _ '" w1, w2  "', [ ' w1, w2  ' ]
    end

    it "single quote in double qoutes" do

      _ '"\'"', [ "'" ]
    end

    it "double quote in single quotes" do

      _ "'\"'", [ '"' ]
    end

    it "escaped quote in quotes" do

      _ '"i \\"love\\" it"', [ 'i "love" it' ]
    end

    it "you can't have a backslash outside of quotes" do

      _against "mom\\'s spagh"
      _error :unexpected_character_in_unquoted_string
    end

    it "remember to close your quotes (double this time)" do

      _against '"a'
      _error :unclosed_quote do | y |
        y.should eql [ 'expecting "\"".' ]
      end
    end

    it "backslash with nothing after it (necessarily in quoted string)" do

      _against '"hi\\'
      _error :escape_character_with_nothing_after_it
    end

    def _ input_s, output_a

      _against input_s
      if @result
        want_no_emissions
        @result.should eql output_a
      else
        ___when_had_no_result
      end
    end

    def ___when_had_no_result
      self._NO
    end

    def _against s

      _x = _subject[ s, & event_log.handle_event_selectively ]
      @result = _x
      NIL_
    end

    def _error sym, & y_p

      _be_this = be_emission :error, :expression, :list_parse_error, sym do |y|
        if y_p
          y_p[ y ]  # (hi.)
        end
      end

      if false == @result
        only_emission.should _be_this
      else
        fail ___say_did_not_fail
      end
    end

    def ___say_did_not_fail
      "did not fail."
    end

    def emission_array
      @__em_a ||= event_log.flush_to_array
    end

    def _subject
      Home_::InteractiveCLI::List_Interpretation_Adapter___
    end
  end
end
