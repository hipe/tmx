require_relative 'test-support'

module Skylab::Headless::TestSupport::System

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe "[hl] system .." do

    it "tmpdir_pathname (memoized)" do
      oid1 = subject.tmpdir_pathname
      oid2 = subject.tmpdir_pathname
      oid1.should eql oid2
    end

    it "tmpdir_path" do
      _build_it_manually = subject.tmpdir_pathname.to_path
      subject.tmpdir_path.should eql _build_it_manually
    end

    it "cache_pathname (bad test)" do
      subject  # yes
      fn = Subject_[]::Defaults___::CACHE_FILE__
      subject.cache_pathname.join( "FOO" ).to_path.
        should be_include( "#{ fn }/FOO" )
    end

    def subject
      Subject_[].defaults
    end

    context "[hl] system instance-methods .." do

      it "does" do
        o = ::Object.new
        o.extend Subject_[]::InstanceMethods
        dodgy = o.instance_exec do
          system.which THE_STANDARD_EDITOR_
        end
        s = dodgy[ - THE_STANDARD_EDITOR_.length .. -1 ]
        s.should eql( THE_STANDARD_EDITOR_ )
      end
    end

    THE_STANDARD_EDITOR_ = 'ed'.freeze

    context "[hl] System.system" do

      it "any_home_directory_path" do
        # #bad-test
        x1 = ::ENV[ 'HOME' ]
        x2 = Subject_[].system.any_home_directory_path
        x2.should eql( x1 )
      end

      it "any_home_directory_pathname" do
        s1 = Subject_[].system.any_home_directory_pathname.join( 'X' ).to_s
        s2 = "#{ ::ENV[ 'HOME' ] }/X"
        s1.should eql( s2 )
      end
    end

    Subject_ = -> do
      Headless_::System
    end
  end
end
