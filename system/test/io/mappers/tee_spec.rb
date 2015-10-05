require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] IO - mappers - tee" do

    context "with 2 downstreams" do

      it "dispatches the message out to both" do
        tee = Home_::IO::Mappers::Tee.new
        tee[:foo] = ::StringIO.new
        tee[:bar] = ::StringIO.new
        tee.write('a')
        tee.puts('b')
        tee << 'c'
        tee[:foo].string.should eql("ab\nc")
        tee[:bar].string.should eql( tee[:foo].string )
      end
    end

    context "with 0 downstreams" do
      it "does nothing" do
        tee = Home_::IO::Mappers::Tee.new
        tee.write('a')
      end
    end

    it "responds to respond_to? appropriately (based on the list)" do
      tee = Home_::IO::Mappers::Tee.new
      tee.respond_to?( :foo ).should eql false
      tee.respond_to?( :puts ).should eql true
    end

    before :all do
      Home_.lib_.string_IO
    end
  end
end
