require_relative 'test-support'

module Skylab::InformationTactics::TestSupport::Summarize
  # Quickie enabled - try just running this file with "ruby -w"

  describe "#{ InformationTactics::Summarize}::Time" do
    it "2 days" do
      time_a = InformationTactics::Library_::Time.parse '2012-06-16 12:01 PM'
      time_b = ::Time.parse '2012-06-18 12:02 PM'
      unit, amt = InformationTactics::Summarize::Time[ time_a - time_b ]
      "#{ amt.to_i } #{ unit }s".should eql('2 days')
    end
  end
end
