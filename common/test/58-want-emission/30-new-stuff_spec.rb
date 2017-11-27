require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] want emission - new stuff" do

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_meta
    use :want_emission

    it "fail to match the full category" do

      o = subject_

      matcher = be_emission :one, :two, :three, :four

      yes = nil
      matcher.singleton_class.send :define_method, :__when_failed do  # oh boy
        yes = true
      end

      _em = o::EventEmission___.new nil, [ :one, :two, :gamma, :potato ]

      matcher.matches? _em

      yes or fail

      _ = matcher.failure_message_for_should

      expect( _ ).to eql "had 'gamma', needed 'three' for the #{
        }third component of [:one, :two, :gamma, :potato]"
    end
  end
end
