require_relative '../test-support'

module Skylab::BeautySalon::TestSupport::CLI::Wrap_  # (no Actions node yet..)

  ::Skylab::BeautySalon::TestSupport::CLI[ Wrap_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ BeautySalon }::CLI wrap" do

    extend Wrap_TestSupport

    def self.client_class ; BeautySalon::CLI::Client end

    it "win" do
      path = TestSupport::Data::Universal_Fixtures.dir_pathname.
        join "one-line.txt"
      invoke 'wrap', '-c14', '-v', path
      lines[:err].shift.should match( /line range union.+1.+infinity/i )
      lines[:out].length.should eql( 5 )
      lines[:out].first.should eql( 'a file with' )
    end
  end
end
