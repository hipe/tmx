require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Formal::Box

  ::Skylab::MetaHell::TestSupport::Formal[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module ModuleMethods
    include Constants

    def new_modified_box
      box = MetaHell_::Formal::Box.new
      class << box
        public :add
      end
      box
    end
  end
end
