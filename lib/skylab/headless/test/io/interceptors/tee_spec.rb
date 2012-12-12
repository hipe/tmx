require_relative 'test-support'

module Skylab::Headless::IO::Interceptors::TestSupport
  extend ::Skylab::TestSupport::Quickie
  describe "#{::Skylab::Headless::IO::Interceptors::Tee}" do
    context "with 2 downstreams" do
      it "dispatches the message out to both" do
        tee = Headless::IO::Interceptors::Tee.new
        tee[:foo] = ::StringIO.new
        tee[:bar] = ::StringIO.new
        tee.write('a')
        tee.puts('b')
        tee << 'c'
        tee[:foo].string.should eql("ab\nc")
        tee[:bar].string.should eql(tee[:foo].string)
      end
    end
    context "with 0 downstreams" do
      it "does nothing" do
        tee = Headless::IO::Interceptors::Tee.new
        tee.write('a')
      end
    end
  end
end
