require_relative 'test-support'

module Skylab::CSS_Convert::TestSupport

  describe "[cssc] CLI integration" do

    extend TS_

    alias_method :u, :unstyle

    let :client do cli_instance end

    let :stderr do
      raw = client.send( :io_adapter ).errstream[ :buffer ].string
      clean = CSSC_._lib.CLI_lib.pen.unstyle raw
      clean.split "\n"
    end

    invite_re = /use nerk -h for help/i

    usage_re = /usage: nerk \[-f\].+\[-v\] <directives-file>\z/

    it "with no args, gives warm, inviting message" do
      client.invoke([]).should eql(-1)
      stderr.shift.should match %r(\Aexpecting <directives-file> or STDIN\z)
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
      stderr.shift.should match %r(\ANo such <directives-file> - .+\bnot-there\.txt\b)
      u(stderr.shift).should match(usage_re)
      u(stderr.shift).should match(invite_re)
      stderr.length.should eql(0)
    end
  end
end
