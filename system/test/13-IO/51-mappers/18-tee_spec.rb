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
        expect( tee[:foo].string ).to eql("ab\nc")
        expect( tee[:bar].string ).to eql( tee[:foo].string )
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
      expect( tee.respond_to?( :foo ) ).to eql false
      expect( tee.respond_to?( :puts ) ).to eql true
    end

    before :all do
      Home_.lib_.string_IO
    end
  end
end
