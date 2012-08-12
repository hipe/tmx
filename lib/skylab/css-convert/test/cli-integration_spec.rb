require_relative 'test-support'
require 'skylab/porcelain/core' # TiteColor#unstylize

module Skylab::CssConvert
  describe "Skylab::CssConvert CLI" do
    include TestSupport::InstanceMethods
    alias_method :u, :unstylize
    let(:client) { cli_instance }
    let(:stderr) { client.io_adapter.errstream[:buffer].string.split("\n") }
    invite_re = /nerk -h for more help/i
    usage_re = /usage: nerk \[-f\].+\[-v\] \[<directives-file>\]\z/
    it "with no args, gives warm, inviting message" do
      # client.io_adapter.debug!
      client.invoke([]).should eql(-1)
      stderr.shift.should be_include('expecting: <directives-file>')
      u(stderr.shift).should match(usage_re)
      u(stderr.shift).should match(invite_re)
      stderr.length.should eql(0)
    end
    it "with too many args, should give friendly, " <<
      "not overbearing emotional support" do
      client.invoke(['a', 'b']).should eql(-1)
      stderr.shift.should match(/unexpected arg.*:.*"b"/i)
      u(stderr.shift).should match(usage_re)
      u(stderr.shift).should match(invite_re)
      stderr.length.should eql(0)
    end
    it "should whine about file not found" do
      client.invoke([fixture_path('not-there.txt').to_s]).should eql(-1)
      stderr.shift.should match(/<directives-file> not found: .+not-there.txt/)
      u(stderr.shift).should match(usage_re)
      u(stderr.shift).should match(invite_re)
      stderr.length.should eql(0)
    end
  end
end
