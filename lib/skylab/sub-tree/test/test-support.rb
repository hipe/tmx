require_relative '../core'

module Skylab::SubTree::TestSupport

  SubTree_ = ::Skylab::SubTree
  Autoloader_ = SubTree_::Autoloader_

  TestSupport_ = Autoloader_.require_sidesystem :TestSupport

  TestSupport_::Regret[ self ]

  TS_ = self

  module Constants
    SubTree_ = SubTree_
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
      SubTree_::API
    end
  end

  Callback_ = SubTree_::Callback_

  DASH_ = SubTree_::DASH_

  EMPTY_S_ = SubTree_::EMPTY_S_

  UNDERSCORE_ = SubTree_::UNDERSCORE_

  module Constants
    Callback_ = Callback_
    DASH_ = DASH_
    EMPTY_A_ = SubTree_::EMPTY_A_
    EMPTY_S_ = EMPTY_S_
    NIL_ = SubTree_::NIL_
    Top_TS_ = TS_
    UNDERSCORE_ = UNDERSCORE_
  end

  NIL_ = nil
end
