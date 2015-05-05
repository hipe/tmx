require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services

  describe "[hl] system services environment" do

    extend TS_

    it "any_home_directory_path (#bad-test)" do

      actual_s = subject.environment.any_home_directory_path
      actual_s.should eql real_home

    end

    it "any_home_directory_pathname (#bad-test)" do

      actual_s = subject.environment.any_home_directory_pathname.join( 'X' ).to_path
      actual_s.should eql "#{ real_home }/X"

    end

    def real_home
      ::ENV[ 'HOME' ]
    end
  end
end
