require_relative 'test-support'
require 'skylab/porcelain/core' # TiteColor#unstylize

module Skylab::CssConvert
  describe "Skylab::CssConvert CLI" do
    include TestSupport::InstanceMethods
    include ::Skylab::Porcelain::TiteColor # unstylize
    let(:client) { cli_instance }
    let(:stderr) { unstylize(client.output_adapter.err[:buffer].string).split("\n") }
    it "with no args, gives warm, inviting message" do
      # client.output_adapter.debug!
      client.invoke([]).should eql(-1)
      stderr.shift.should be_include('expecting: <directives-file>')
      stderr.shift.should be_include('usage: nerk [-f] [-d] [-v] [-h] <directives-file>')
      stderr.shift.should be_include('nerk -h for help')
      stderr.length.should eql(0)
    end
    invite_re = /nerk -h for help/i
    usage_re  = /\Ausage:/i
    it "with too many args, should give friendly, not overbearing emotional support" do
      client.invoke(['a', 'b']).should eql(-1)
      stderr.shift.should match(/unexpected arg.*:.*"b"/i)
      stderr.shift.should match(usage_re)
      stderr.shift.should match(invite_re)
      stderr.length.should eql(0)
    end
    it "should whine about file not found" do
      client.invoke([fixture_path('not-there.txt').to_s]).should eql(-1)
      stderr.shift.should match(/directives file not found: .+not-there.txt/)
      stderr.shift.should match(usage_re)
      stderr.shift.should match(invite_re)
      stderr.length.should eql(0)
    end
  end
end
