require_relative 'test-support'

module Skylab::TaskExamples::TestSupport

  describe "[te] version" do

    it "parses the minimal case" do
      _parse "1.2"
    end

    it "parses the minimal case with patch version" do
      _parse "1.2.3"
    end

    it "parses abc1.23.45" do
      _parse "abc1.23.45"
    end

    it "parses 12.345.67abc" do
      _parse "12.345.67abc"
    end

    it "whines on ambiguity" do
      ui = _UI_Spy.new silent: true
      str = "abc1.2.3def4.5"
      sexp = Home_::Version.parse_string_with_version str do |o|
        o.on_error do |e|
          ui.err.puts e.text
        end
      end
      sexp.should eql( false )
      ui.err_string.strip.should eql("multiple version strings matched in string: \"abc1.2.3def4.5\"")
    end

    it "allows version bumps" do
      sexp = Home_::Version::parse_string_with_version( "abc-1.4.7-def" )
      ver = sexp.child( :version )
      ver.class.should eql( Home_::Version )
      ver.unparse.should eql( "1.4.7" )
      ver.bump! :major
      sexp.unparse.should eql( "abc-2.4.7-def" )
      ver.bump! :major
      sexp.unparse.should eql( "abc-3.4.7-def" )
      ver.bump! :minor
      sexp.unparse.should eql( "abc-3.5.7-def" )
      ver.bump! :patch
      sexp.unparse.should eql( "abc-3.5.8-def" )
      -> do
        ver.bump! :not_there
      end.should raise_error( ::RuntimeError, "no such node: :not_there" )
    end

    def _parse str
      ui = _UI_Spy.new
      sexp = Home_::Version::parse_string_with_version(str) do |o|
        o.on_informational { |e| ui.err.puts("#{e.stream_symbol}: #{e.text}") }
      end
      sexp.unparse.should eql(str)
      ui.err_string.should eql("")
    end

    def _UI_Spy
      TestLib_::Task[].test_support.lib :UI_spy
    end
  end
end
