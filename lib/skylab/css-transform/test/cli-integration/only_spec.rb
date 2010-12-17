require File.dirname(__FILE__) + '/../testlib.rb' unless Object.const_defined? 'Hipe__CssConvert__Testlib'

module BlahSpec
  describe Hipe::CssConvert::Cli do
    it "should give helpful message with no error" do
      c = new_cli
      c.run([]).should == 1
      c.out.flush.should match(/^Usage: ([^ ]+) \[file\]$/)
    end
    it "should give helpful message with too many args" do
      c = new_cli
      c.run(['a', 'b']).should == 1
      c.out.flush.should match(/^Usage: ([^ ]+) \[file\]$/)
    end
    it "should whine about file not found" do
      c = new_cli
      c.run([fixture_path('not-there.txt')]).should == 1
      s = c.err.flush
      s.should == "File not found: test/fixtures/not-there.txt\n"
    end
  end
end