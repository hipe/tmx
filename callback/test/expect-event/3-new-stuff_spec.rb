require_relative '../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] expect event - (3) new stuff" do

    TS_.etc_ self
    use :memoizer_methods
    use :expect_event_meta
    use :expect_event

    it "fail to match the full category" do

      o = subject_

      matcher = be_emission :one, :two, :three, :four

      yes = nil
      matcher.singleton_class.send :define_method, :__when_failed do  # oh boy
        yes = true
      end

      _em = o::Emission___.new nil, [ :one, :two, :gamma, :potato ]

      matcher.matches? _em

      yes or fail

      _ = matcher.failure_message_for_should

      _.should eql "had 'gamma', needed 'three' for the #{
        }third component of [:one, :two, :gamma, :potato]"
    end
  end
end
