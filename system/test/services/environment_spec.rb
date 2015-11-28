require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] services - environment" do

    TS_[ self ]

    it "any_home_directory_path (#bad-test)" do

      actual_s = _subject.any_home_directory_path
      actual_s.should eql _real_home

    end

    it "any_home_directory_pathname (#bad-test)" do

      actual_s = _subject.any_home_directory_pathname.join( 'X' ).to_path
      actual_s.should eql "#{ _real_home }/X"

    end

    def _real_home
      ::ENV[ 'HOME' ]
    end

    def _subject
      services_.environment
    end
  end
end
