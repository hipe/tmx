module Skylab::Brazen

  module Data_Store_

    class Model_ < Brazen_::Model_
      NAME_STOP_INDEX = 1  # sl brzn datastore actions couch add
    end

    class Action < Brazen_::Model_::Action
      NAME_STOP_INDEX = 1
    end
  end
end
