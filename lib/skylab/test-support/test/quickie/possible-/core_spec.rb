require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Quickie::Possible_

  describe "#{ Quickie::Possible_ } core" do  # this line is last `Q_uickie`

    context "with a graph with three nodes" do

      before :all do

        module Zing

          Possible_::Graph_[ self ]

          BEGINNING = eventpoint

          MIDDLE = eventpoint do
            from BEGINNING
          end

          ENDING = eventpoint do
            from MIDDLE
            from BEGINNING
          end
        end
      end

      def possible_graph
        Zing.possible_graph
      end

      it "oh look a graph (it did the inversion)" do
        s = possible_graph.to_text
        s.should eql( <<-HERE.unindent.chomp )
          BEGINNING -> MIDDLE
          BEGINNING -> ENDING
          MIDDLE -> ENDING
        HERE
      end
    end
  end
end
