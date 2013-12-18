require_relative 'test-support'

module Skylab::CssConvert::TestSupport

  describe "Skylab::CssConvert CLI" do

    extend CssConvert_TestSupport

    alias_method :u, :unstyle

    let :client do cli_instance end

    let :stderr do
      raw = client.send( :io_adapter ).errstream[ :buffer ].string
      clean = Headless::CLI::Pen::FUN.unstyle[ raw ]
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
      _argv = [ fixture_path( 'not-there.txt' ).to_s ]
      _client = client
      @result = _client.invoke _argv
      expect_whine_about_directives_file_not_found
      @result.should eql( -1 )
    end

    define_method :expect_whine_about_directives_file_not_found do
      stderr.shift.should match(/<directives-file> not found: .+not-there.txt/)
      u(stderr.shift).should match(usage_re)
      u(stderr.shift).should match(invite_re)
      stderr.length.should eql(0)
    end
  end
end
