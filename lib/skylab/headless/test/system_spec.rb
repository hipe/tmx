require_relative 'test-support'

module Skylab::Headless::TestSupport::System

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless }::System.." do

    it "tmpdir_pathname (memoized)" do
      oid1 = Headless::System.defaults.tmpdir_pathname
      oid2 = Headless::System.defaults.tmpdir_pathname
      oid1.should eql( oid2 )
    end

    it "tmpdir_path" do
      sys_defaults.tmpdir_path.should eql( sys_defaults.tmpdir_pathname.to_s )
    end

    it "cache_pathname" do
      bad_test = Headless::System::Defaults_::CACHE_FILE_
      sys_defaults.cache_pathname.join( "FOO" ).to_s.
        should be_include( "#{ bad_test }/FOO" )
    end

    def sys_defaults
      Headless::System.defaults
    end

    context "#{ Headless }::System::InstanceMethods.." do
      it "does" do
        o = ::Object.new
        o.extend Headless::System::InstanceMethods
        dodgy = o.instance_exec do
          system.which THE_STANDARD_EDITOR_
        end
        s = dodgy[ - THE_STANDARD_EDITOR_.length .. -1 ]
        s.should eql( THE_STANDARD_EDITOR_ )
      end
    end

    THE_STANDARD_EDITOR_ = 'ed'.freeze

    context "#{ Headless }::System.system" do

      it "any_home_directory_path" do
        # #bad-test
        x1 = ::ENV[ 'HOME' ]
        x2 = Headless::System.system.any_home_directory_path
        x2.should eql( x1 )
      end

      it "any_home_directory_pathname" do
        s1 = Headless::System.system.any_home_directory_pathname.join( 'X' ).to_s
        s2 = "#{ ::ENV[ 'HOME' ] }/X"
        s1.should eql( s2 )
      end
    end
  end
end
