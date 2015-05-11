require_relative 'test-support'

module Skylab::Callback::TestSupport::Scn::Articulators::Eventing

  ::Skylab::Callback::TestSupport::Scn::Articulators[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ca] scn articulators - eventing" do

    context "can operate in \"scanner\" mode or \"buffering\" mode" do

      before :all do

        EX1 = Subject_[].eventing(
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
          end )

      end

      it "builds" do
      end

      it "\"pull\"-style: use `with` to get a dup, set `gets_under`, call `gets`" do
        scn = EX1.new_with :gets_under, Callback_::Stream.via_nonsparse_array( [ :A ] )
        x = scn.gets
        x.should eql "[#{ NEWLINE_ } A"
        x = scn.gets
        x.should eql "#{ NEWLINE_ }]"
        scn.gets.should be_nil
      end

      it "when zero input items" do
        scn = EX1.new_with :gets_under, Callback_::Stream.the_empty_stream
        x = scn.gets
        x.should eql '[ ]'
        scn.gets.should be_nil
      end

      it "will change to buffering mode with multiple `puts` and then `flush`" do
        scn = EX1.dup
        scn.puts 'hi'
        scn.puts 'hej'
        scn.flush.should eql "[#{ NEWLINE_ } hi,#{ NEWLINE_ } hej#{ NEWLINE_ }]"
        scn.flush.should eql '[ ]'
      end

      it "when zero input items and buffering mode" do
        scn = EX1.dup
        scn.flush.should eql "[ ]"
        scn.flush.should eql '[ ]'
      end
    end
  end
end
