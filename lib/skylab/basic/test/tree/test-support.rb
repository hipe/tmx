require_relative '../test-support'

module Skylab::Basic::TestSupport::Tree_TS

  ::Skylab::Basic::TestSupport[ TS_ = self, :filename, 'tree' ]

  include Constants

  extend TestSupport_::Quickie

  module ModuleMethods

    def memoize_ i, & p
      define_method i, ( Callback_.memoize do
        p[]
      end )
    end
  end

  module InstanceMethods

    def via_paths_ * x_a
      Subject_[].via :paths, x_a
    end

    define_method :deindent_, -> do
      _RX = /^[ ]{8}/
      -> s do
        s.gsub! _RX, EMPTY_S_
        s
      end
    end.call
  end

  Subject_ = -> do
    Home_::Tree
  end

  o = Home_

  Callback_ = o::Callback_
  EMPTY_A_ = o::EMPTY_A_
  EMPTY_P_ = o::EMPTY_P_
  EMPTY_S_ = o::EMPTY_S_
  NIL_ = o::NIL_

  module Constants
    Subject_ = Subject_
  end

  Home_ = Home_
end

# #tombstone legacy artifacts of early early test setup
