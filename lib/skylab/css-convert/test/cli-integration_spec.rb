require_relative 'test-support'

module Skylab::CssConvert::TestSupport

  describe "Skylab::CssConvert CLI" do

    extend CssConvert_TestSupport

    alias_method :u, :unstylize

    let :client do cli_instance end

    let :stderr do
      raw = client.send( :io_adapter ).errstream[ :buffer ].string
      clean = Headless::CLI::Pen::FUN.unstylize[ raw ]
      clean.split "\n"
    end

    invite_re = /use nerk -h for help/i

    usage_re = /usage: nerk \[-f\].+\[-v\] <directives-file>\z/

    it "with no args, gives warm, inviting message" do
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
