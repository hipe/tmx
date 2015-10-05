require 'skylab/sub_tree'

module Skylab::SubTree::TestSupport

  Home_ = ::Skylab::SubTree
  Autoloader_ = Home_::Autoloader_

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  module Constants
    Home_ = Home_
    TestSupport_ = TestSupport_
  end

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      const_i = Callback_::Name.via_variegated_symbol( sym ).as_const
      mod = nearest_test_node

      begin

        if mod.const_defined? const_i, false
          found = mod.const_get const_i
          break
        end

        mod = mod.parent_anchor_module

        redo
      end while nil

      found[ self ]
      NIL_
    end
  end

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :fixture_tree, -> do
      h = {}
      -> sym do
        h.fetch sym do
          h[ sym ] = TS_.dir_pathname.join(
            "fixture-trees/#{ sym.id2name.gsub UNDERSCORE_, DASH_ }" ).
              to_path.freeze
        end
      end
    end.call

    def subject_API
      Home_::API
    end
  end

  Expect_Event = -> tcm do

    tcm.include Callback_.test_support::Expect_event::Test_Context_Instance_Methods

  end

  Callback_ = Home_::Callback_

  DASH_ = Home_::DASH_

  EMPTY_S_ = Home_::EMPTY_S_

  UNDERSCORE_ = Home_::UNDERSCORE_

  module Constants
    Callback_ = Callback_
    DASH_ = DASH_
    EMPTY_A_ = Home_::EMPTY_A_
    EMPTY_S_ = EMPTY_S_
    NIL_ = Home_::NIL_
    Top_TS_ = TS_
    UNDERSCORE_ = UNDERSCORE_
  end

  NIL_ = nil
end