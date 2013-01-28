require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Box
  ::Skylab::MetaHell::TestSupport::Formal[ Box_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module ModuleMethods
    include CONSTANTS

    def new_modified_box
      box = MetaHell::Formal::Box.new
      class << box
        public :add
      end
      box
    end
  end
end
