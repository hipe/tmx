require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_Tree

  ts = ::Skylab::SubTree::TestSupport

  ts.autoloaderize_with_filename_child_node 'models/tree', self

  ts[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def fp * x_a
      Subject_[].from :paths, x_a
    end

    define_method :deindent, -> do
      _RX = /^[ ]{8}/
      -> s do
        s.gsub! _RX, EMPTY_S_
        s
      end
    end.call
  end

  Callback_ = SubTree_::Callback_

  EMPTY_A_ = SubTree_::EMPTY_A_
  EMPTY_P_ = SubTree_::EMPTY_P_
  EMPTY_S_ = SubTree_::EMPTY_S_

  Subject_ = -> do
    SubTree_::Models::Tree
  end

  module Constants
    Subject_ = Subject_
  end
end

# #tombstone legacy artifacts of early early test setup
