require File.expand_path('../../version', __FILE__)
require File.expand_path('../support/ui-tee', __FILE__)

module Skylab::Dependency
  include Test::Support # UiTee

  describe Version do

    it "should parse the minimal case" do
      _parse "1.2"
    end
    it "should parse minimal case with patch version" do
      _parse "1.2.3"
    end
    it "should parse abc1.23.45" do
      _parse "abc1.23.45"
    end
    it "should parse 12.345.67abc" do
      _parse "12.345.67abc"
    end
    it "should whine with ambiguity" do
      ui = UiTee.new
      str = "abc1.2.3def4.5"
      sexp = Version::parse_string_with_version(str, :ui => ui)
      sexp.should eq(false)
      ui.out_string.should eq("")
      ui.err_string.strip.should eq("Skylab::Dependency::Version ERROR: multiple version strings matched in string: \"abc1.2.3def4.5\"")
    end
    it "should allow bumps" do
      sexp = Version::parse_string_with_version("abc-1.4.7-def")
      ver = sexp.detect(:version)
      ver.class.should eq(Version)
      ver.to_s.should eq("1.4.7")
      ver.bump!(:major)
      sexp.to_s.should eq("abc-2.4.7-def")
      ver.bump!(:major)
      sexp.to_s.should eq("abc-3.4.7-def")
      ver.bump!(:minor)
      sexp.to_s.should eq("abc-3.5.7-def")
      ver.bump!(:patch)
      sexp.to_s.should eq("abc-3.5.8-def")
      lambda { ver.bump!(:not_there) }.should raise_error(ArgumentError, "no such node: :not_there")
    end
    include Test::Support # UiTee (again)
    def _parse str
      ui = UiTee.new
      sexp = Version::parse_string_with_version(str, :ui => ui)
      sexp.to_s.should eq(str)
      ui.err_string.should eq("")
      ui.out_string.should eq("")
    end
  end
end

