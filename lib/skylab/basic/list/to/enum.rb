module Skylab::Basic

  module List::To::Enum

    def self.[] x
      List::From.const_get( List::From[ x ], false )::To::Enum[ x ]
    end
  end
end
