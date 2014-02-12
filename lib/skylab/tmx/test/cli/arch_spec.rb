require_relative 'test-support'

module Skylab::TMX::TestSupport::CLI::Arch

  ::Skylab::TMX::TestSupport::CLI[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "tmx CLI arch" do

    extend TS_

    def self.client_class
      TMX::CLI
    end

    def self.with i
      define_singleton_method :with_value do i end
    end

    context "cli" do

      with :cli

      it "pings" do
        x = invoke 'arch', 'cli', 'ping'
        x.should eql( :hello_from_cli )
        expect_hello
      end
    end

    context "git viz" do

      with :git_viz

      it "pings" do
        x = invoke 'arch', 'git-viz', 'ping'
        x.should eql( :hello_from_git_viz )
        expect_hello
      end
    end

    context "jshint" do

      with :jshint

      it "pings" do
        x = invoke 'arch', 'jshint', 'ping'
        x.should eql( :hello_from_jshint )
        expect_hello
      end
    end

    context "nginx" do

      with :nginx

      it "pings" do
        x = invoke 'arch', 'nginx', 'ping'
        x.should eql( :hello_from_nginx )
        expect_hello
      end
    end

    context "nginx" do

      with :nginx

      it "pings" do
        x = invoke 'arch', 'nginx', 'ping'
        x.should eql( :hello_from_nginx )
        expect_hello
      end
    end

    context "schema" do

      with :schema

      it "pings" do
        x = invoke 'arch', 'schema', 'ping'
        x.should eql( :hello_from_schema )
        expect_hello
      end
    end

    context "team city" do

      with :team_city

      it "pings" do
        x = invoke 'arch', 'team-city', 'ping'
        x.should eql( :hello_from_team_city )
        expect_hello
      end
    end

    context "xpdf" do

      with :xpdf

      it "pings" do
        x = invoke 'arch', 'xpdf', 'ping'
        x.should eql( :hello_from_xpdf )
        expect_hello
      end
    end

    def expect_hello
      a = lines[ :err ]
      line = a.fetch( 0 )
      expect = "hello from #{ self.class.with_value.to_s.gsub( '_', ' ' ) }."
      line.should eql( expect )
      a.length.should eql( 1 )
    end
  end
end
