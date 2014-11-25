module Skylab::TestSupport

  module Regret::API

    class Actions::DocTest

      module Models_::Constant_

        # if x isn't valid write a message to y and result in false-ish.
        # if x is valid result is true-ish. if you want to change its value
        # to make it valid or otherwise normalize it, write it to `p`.
        # behavior is undefined if you result in falseish and write to `p`.

        def validate y, x, _p=nil
          if RX_ =~ x then true else
            y.say :notice, -> do
              "does not look like a constant - #{ ick x }"
            end
            false
          end
        end
        module_function :validate

        RX_ = /\A(?:::)?[A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*\z/
      end
    end
  end
end
