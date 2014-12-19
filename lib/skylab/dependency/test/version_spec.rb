require_relative 'test-support'
require 'skylab/slake/test/test-support'

module Skylab::Dependency::TestSupport

  include ::Skylab::Slake::TestSupport # so it's avail in s.c. calls below

  Slake_TestSupport::UI::Tee || nil #(#kick) laod it now so prettier below

  describe Dep_::Version do

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

    it "whines on ambiguity" do
      ui = UI::Tee.new silent: true
      str = "abc1.2.3def4.5"
      sexp = Dep_::Version.parse_string_with_version str do |o|
        o.on_error do |e|
          ui.err.puts e.text
        end
      end
      sexp.should eql( false )
      ui.err_string.strip.should eql("multiple version strings matched in string: \"abc1.2.3def4.5\"")
    end

    it "allows version bumps" do
      sexp = Dep_::Version::parse_string_with_version( "abc-1.4.7-def" )
      ver = sexp.child( :version )
      ver.class.should eql( Dep_::Version )
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
      ui = UI::Tee.new
      sexp = Dep_::Version::parse_string_with_version(str) do |o|
        o.on_informational { |e| ui.err.puts("#{e.stream_symbol}: #{e.text}") }
      end
      sexp.unparse.should eql(str)
      ui.err_string.should eql("")
    end
  end
end
