require_relative 'test-support'
require 'skylab/slake/test/test-support'

module Skylab::Dependency::TestSupport
  include ::Skylab::Slake::TestSupport # so it's avail in s.c. calls below
  Slake_TestSupport::UI::Tee || nil #(#kick) laod it now so prettier below

  describe Dependency::Version do
    include Dependency_TestSupport # so constants are avail. in i.m.'s below

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
    it "whines on ambiguity", f:true do
      ui = UI::Tee.new silent: true
      str = "abc1.2.3def4.5"
      sexp = Dependency::Version.parse_string_with_version(str) do |o|
        o.on_error { |e| ui.err.puts e.message }
      end
      sexp.should eq(false)
      ui.err_string.strip.should eq("multiple version strings matched in string: \"abc1.2.3def4.5\"")
    end
    it "allows version bumps" do
      sexp = Dependency::Version::parse_string_with_version("abc-1.4.7-def")
      ver = sexp.detect(:version)
      ver.class.should eq(Dependency::Version)
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
    def _parse str
      ui = UI::Tee.new
      sexp = Dependency::Version::parse_string_with_version(str) do |o|
        o.on_informational { |e| ui.err.puts("#{e.stream_name}: #{e.message}") }
      end
      sexp.unparse.should eq(str)
      ui.err_string.should eq("")
    end
  end
end
