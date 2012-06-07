require File.expand_path('../../version', __FILE__)
require 'skylab/slake/test/support/ui-tee'
require File.expand_path('../support', __FILE__)

module Skylab::Dependency::TestSupport
  include ::Skylab::Slake::TestSupport # UiTee
  include ::Skylab::Dependency

  describe Version do

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
      ui = UiTee.new(:silent => true)
      str = "abc1.2.3def4.5"
      sexp = Version.parse_string_with_version(str) do |o|
        o.on_error { |e| ui.err.puts e.message }
      end
      sexp.should eq(false)
      ui.err_string.strip.should eq("multiple version strings matched in string: \"abc1.2.3def4.5\"")
    end
    it "allows version bumps" do
      sexp = Version::parse_string_with_version("abc-1.4.7-def")
      ver = sexp.detect(:version)
      ver.class.should eq(Version)
      ver.unparse.should eq("1.4.7")
      ver.bump!(:major)
      sexp.unparse.should eq("abc-2.4.7-def")
      ver.bump!(:major)
      sexp.unparse.should eq("abc-3.4.7-def")
      ver.bump!(:minor)
      sexp.unparse.should eq("abc-3.5.7-def")
      ver.bump!(:patch)
      sexp.unparse.should eq("abc-3.5.8-def")
      lambda { ver.bump!(:not_there) }.should raise_error(::RuntimeError, "no such node: :not_there")
    end
    include TestSupport # UiTee (again)
    def _parse str
      ui = UiTee.new
      sexp = Version::parse_string_with_version(str) do |o|
        o.on_informational { |e| ui.err.puts("#{e.type}: #{e.message}") }
      end
      sexp.unparse.should eq(str)
      ui.err_string.should eq("")
    end
  end
end

