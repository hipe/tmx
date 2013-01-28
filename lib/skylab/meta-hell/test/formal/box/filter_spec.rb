require_relative 'test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Box

  describe "#{ MetaHell::Formal::Box } - filters" do

    extend Box_TestSupport

    context "filters" do

      st = ::Struct.new :red, :blue

      subject -> do
        box = new_modified_box
        box.add :one, st.new( true, false )
        box.add :two, st.new( false, true )
        box.add :three, st.new( true, true )
        box
      end

      it "2 arg then 2 arg" do
        ea = subject.each
        ea2 = ea.filter -> k, v do
          v.red
        end
        a = []
        ea2.each do |k, v|
          a << [k, v]
        end
        a.length.should eql( 2 )
        k, v = a.first
        k.should eql( :one )
        v.red.should eql( true )
      end

      it "1 arg then 1 arg" do
        ea = subject.each
        ea2 = ea.filter -> x do
          x.blue
        end
        a = []
        ea2.each do |x|
          a << x
        end
        a.map(&:red).should eql( [false, true] )
      end

      it "1 arg then 1 arg map" do
        ea = subject.each
        ea2 = ea.filter -> x do
          x.blue
        end
        a = ea2.map do |x|
          x.red
        end
        a.should eql( [false, true] )
      end

      it "1 arg filter, then two arg filter, then a reduce #{
        } (FILTER COMPOSITION)" do

        ea = subject.filter -> x do
          x.red
        end
        ea2 = ea.filter -> k, v do
          :three == k and true == v.blue
        end
        a = ea2.reduce [] do |m, (k,x)| # always keys for you here
          m << x ; m
        end
        a.length.should eql( 1 )
        a.first.red.should eql( true )
      end

      it "2 arg filter, then 2 arg map" do
        ea = subject.filter -> k, v do
          :three == k or false == v.red
        end
        a = ea.map do |k, v|
          [k, v]
        end
        a.length.should eql( 2 )
        a.first.first.should eql( :two )
        a.last.last.blue.should eql( true )
      end
    end
  end
end
