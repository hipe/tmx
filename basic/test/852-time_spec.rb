require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] time - EN - summarize" do

    it "2 days" do

      time_a = Home_.lib_.time.parse '2012-06-16 12:01 PM'
      time_b = ::Time.parse '2012-06-18 12:02 PM'
      unit, amt = _subject_against time_a - time_b
      expect( "#{ amt.to_i } #{ unit }s" ).to eql '2 days'
    end

    def _subject_against x
      Home_::Time::EN::Summarize[ x ]
    end
  end
end
