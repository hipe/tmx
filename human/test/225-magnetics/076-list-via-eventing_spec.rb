require_relative '../test-support'

module Skylab::Human::TestSupport

  describe "[hu] magnetics - list via eventing" do

    TS_[ self ]
    use :memoizer_methods

    context "can operate in \"scanner\" mode or \"buffering\" mode" do

      dangerous_memoize :_subject do

        su = _something_about_eventing(
          :always_at_the_beginning, -> y do
            y << '['
          end,
          :iff_zero_items, -> y do
            y << ' ]'
          end,
          :any_first_item, -> y, x do
            y << "#{ NEWLINE_ } #{ x }"
          end,
          :any_subsequent_items, -> y, x do
            y << ",#{ NEWLINE_ } #{ x }"
          end,
          :at_the_end_iff_nonzero_items, -> y do
            y << "#{ NEWLINE_ }]"
          end,
        )
        SESLtE_EX1 = su
        su
      end

      it "builds" do
        _subject
      end

      it "\"pull\"-style: use `with` to get a dup, set `gets_under`, call `gets`" do
        scn = _subject.with :gets_under, Home_::Stream_[ [ :A ] ]
        x = scn.gets
        expect( x ).to eql "[#{ NEWLINE_ } A"
        x = scn.gets
        expect( x ).to eql "#{ NEWLINE_ }]"
        expect( scn.gets ).to be_nil
      end

      it "when zero input items" do
        scn = _subject.with :gets_under, Common_::THE_EMPTY_STREAM
        x = scn.gets
        expect( x ).to eql '[ ]'
        expect( scn.gets ).to be_nil
      end

      it "will change to buffering mode with multiple `puts` and then `flush`" do
        scn = _subject.dup
        scn.puts 'hi'
        scn.puts 'hej'
        expect( scn.flush ).to eql "[#{ NEWLINE_ } hi,#{ NEWLINE_ } hej#{ NEWLINE_ }]"
        expect( scn.flush ).to eql '[ ]'
      end

      it "when zero input items and buffering mode" do
        scn = _subject.dup
        expect( scn.flush ).to eql "[ ]"
        expect( scn.flush ).to eql '[ ]'
      end
    end

    a = [ :list, :via, :eventing ]
    define_method :_something_about_eventing do |*x_a|
      x_a[ 0, 0 ] = a
      Home_::Sexp.__expression_session_via_sexp x_a
    end
  end
end
