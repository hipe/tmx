require_relative '../../test-support'

describe "[hu] NLP EN number" do

  -> do

    m = :number
    d = 42388
    s = "forty two thousand three hundred eighty eight"

    it "via #{ m }, #{ s } becomes #{ d }" do
      _common s, d, m
    end
  end.call

  -> do

    m = :num2ord
    d = 42388
    s = "forty two thousand three hundred eighty eighth"

    it "via #{ m }, #{ s } becomes #{ d }" do
      _common s, d, m
    end
  end.call

  def _common s, d, m

    ::Skylab::Human::NLP::EN::Number.send( m, d ).should eql s
  end
end
